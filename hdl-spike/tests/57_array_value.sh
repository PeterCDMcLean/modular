#!/usr/bin/env bash
# Array[T, N] as a hardware payload: ports, fields, registers, 4-state, Sim.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
out="$root/hdl-spike/build"
inc=(-I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike"
     -I "$HOME/bitlib-mojo")

mkdir -p "$out"

export MODULAR_HOME="${MODULAR_HOME:-$root/hdl-spike/.modular}"
if [[ ! -f "$MODULAR_HOME/modular.cfg" ]]; then
  rt="$root/bazel-bin/Mojo/libKGENCompilerRTShared.so"
  if [[ ! -f "$rt" ]]; then
    rt="$(find -L "$root/bazel-bin" -name libKGENCompilerRTShared.so -print -quit 2>/dev/null || true)"
  fi
  if [[ -z "$rt" ]]; then
    echo "57_array_value: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/57_array_value.mojo"

"$MOJO" build --emit=circt -o "$out/57_array_value.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/57_array_value.mlir" \
    "$out/57_array_value.mlir"

[ "$(grep -c 'hw.module' "$out/57_array_value.mlir")" = "7" ]
# Value ports and registers flatten to a 32-bit payload.
grep -q 'hw.module @ArrayPass(in %a : i32, out out : i32)' \
    "$out/57_array_value.mlir"
grep -q 'seq.compreg %a, %clk reset %rst' "$out/57_array_value.mlir"
# Dynamic element read shifts the packed value.
grep -q 'comb.shru %a, %1 : i32' "$out/57_array_value.mlir"
# Dynamic element update masks, shifts, and merges.
grep -q 'comb.or %6, %4 : i32' "$out/57_array_value.mlir"
# A constructor constant becomes the field's reset/power-on value.
grep -q 'c67305985_i32' "$out/57_array_value.mlir"
# 4-state arrays carry a value port and a mask port.
grep -q 'hw.module @LogicArrayPass(in %a : i32, in %a_xz : i32, out out : i32, out out_xz : i32)' \
    "$out/57_array_value.mlir"

"$MOJO" build --emit=sv -o "$out/57_array_value.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/57_array_value.raw.sv" | grep -v '^$' \
    > "$out/57_array_value.sv"
diff -u "$root/hdl-spike/expected/57_array_value.sv" \
    "$out/57_array_value.sv"

grep -q 'input  wire \[31:0\] a' "$out/57_array_value.sv"
grep -q "var logic \[31:0\] _GEN_0 = 32'h4030201;" \
    "$out/57_array_value.sv"
grep -q '_GEN_0\[7:0\]' "$out/57_array_value.sv"
grep -q 'out_xz' "$out/57_array_value.sv"

# Native Sim: packed constructor lanes, element set/copy, 4-state, register.
"$MOJO" run "${inc[@]}" "$root/hdl-spike/tests/57_sim_array.mojo" \
    > "$out/57_sim_array.txt"
grep -q '^a 1 2 3 4$' "$out/57_sim_array.txt"
grep -q '^set 1 9$' "$out/57_sim_array.txt"
grep -q '^copy 9$' "$out/57_sim_array.txt"
grep -q '^logic 5 0$' "$out/57_sim_array.txt"
grep -q '^reg 9 1$' "$out/57_sim_array.txt"

echo "57_array_value: ok"
