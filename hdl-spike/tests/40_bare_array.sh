#!/usr/bin/env bash
# Bare register arrays: static and dynamic Array[Reg[T],N] element access.
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
    echo "40_bare_array: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/40_bare_array.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/40_bare_array.mojo"
diff -u "$root/hdl-spike/expected/40_bare_array.mlir" "$out/40_bare_array.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/40_bare_array.mlir")" = "10" ]
grep -q 'hw.module @BareArray(in %addr : i64, in %wd : i8, in %we : i1' \
    "$out/40_bare_array.mlir"
grep -q 'hw.module @StaticArray(in %wd : i8, in %we : i1' \
    "$out/40_bare_array.mlir"
grep -q 'hw.module @LogicArray(in %addr : i64, in %wd : i8, in %wd_xz : i8' \
    "$out/40_bare_array.mlir"
grep -q 'sym @mem_0_3 %wd, %clk' "$out/40_bare_array.mlir"
grep -q 'sym @mem_0_0_xz %wd_xz, %clk' "$out/40_bare_array.mlir"
grep -q 'comb.icmp eq %addr, %c3_i64' "$out/40_bare_array.mlir"
grep -q 'hw.output %9, %10 : i8, i8' "$out/40_bare_array.mlir"

"$MOJO" build --emit=sv -o "$out/40_bare_array.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/40_bare_array.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/40_bare_array.raw.sv" \
    | grep -v '^$' > "$out/40_bare_array.sv"
diff -u "$root/hdl-spike/expected/40_bare_array.sv" "$out/40_bare_array.sv"
grep -q 'module BareArray(' "$out/40_bare_array.sv"
grep -q 'module StaticArray(' "$out/40_bare_array.sv"
grep -q 'module LogicArray(' "$out/40_bare_array.sv"
grep -q "assign _GEN_2 = we & addr == 64'h0;" "$out/40_bare_array.sv"
grep -q 'assign out = _GEN_1 ? mem_0_1 : mem_0_0;' "$out/40_bare_array.sv"
grep -q 'mem_0_0_xz <= wd_xz;' "$out/40_bare_array.sv"
grep -q 'out_xz' "$out/40_bare_array.sv"

echo "40_bare_array: ok"
