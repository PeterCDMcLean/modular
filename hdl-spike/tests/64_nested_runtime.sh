#!/usr/bin/env bash
# Nested runtime loops: an inner range loop inside an outer range loop.
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
    echo "64_nested_runtime: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/64_nested_runtime.mojo"

"$MOJO" build --emit=circt -o "$out/64_nested_runtime.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/64_nested_runtime.mlir" \
    "$out/64_nested_runtime.mlir"

[ "$(grep -c 'hw.module' "$out/64_nested_runtime.mlir")" = "1" ]
# Outer and inner counters with independent in-range compares.
grep -q 'comb.icmp ult %1, %outer : i64' "$out/64_nested_runtime.mlir"
grep -q 'comb.icmp ult %4, %inner : i64' "$out/64_nested_runtime.mlir"
grep -q 'comb.and %2, %5 : i1' "$out/64_nested_runtime.mlir"
# The index combines both counters.
grep -q 'comb.mul %1, %c2_i64 : i64' "$out/64_nested_runtime.mlir"
grep -q 'comb.add %7, %4 : i64' "$out/64_nested_runtime.mlir"
# The inner counter advances/reset, the outer advances on inner completion.
grep -q 'comb.mux %6, %45, %c0_i64_16 : i64' "$out/64_nested_runtime.mlir"
grep -q 'comb.mux %44, %50, %1 : i64' "$out/64_nested_runtime.mlir"
grep -q 'seq.compreg %49, %clk reset %rst' "$out/64_nested_runtime.mlir"
grep -q 'seq.compreg.ce sym @reg_2 %55, %clk, %53' \
    "$out/64_nested_runtime.mlir"

"$MOJO" build --emit=sv -o "$out/64_nested_runtime.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/64_nested_runtime.raw.sv" | grep -v '^$' \
    > "$out/64_nested_runtime.sv"
diff -u "$root/hdl-spike/expected/64_nested_runtime.sv" \
    "$out/64_nested_runtime.sv"

[ "$(grep -c 'var logic \[7:0\]  mem_0_' "$out/64_nested_runtime.sv")" = "8" ]
[ "$(grep -c '_GEN_12 & en & _GEN_13 == 64.h' "$out/64_nested_runtime.sv")" = "8" ]
grep -q 'wire             _GEN_15 = _GEN_12 & _GEN_14 == inner;' \
    "$out/64_nested_runtime.sv"
grep -q 'wire             _GEN_17 = _GEN_15 & _GEN_16 == outer;' \
    "$out/64_nested_runtime.sv"
grep -q '_GEN_18 <= _GEN_17;' "$out/64_nested_runtime.sv"
grep -q 'else if (_GEN_18)' "$out/64_nested_runtime.sv"
grep -q 'assign out = reg_1;' "$out/64_nested_runtime.sv"

echo "64_nested_runtime: ok"
