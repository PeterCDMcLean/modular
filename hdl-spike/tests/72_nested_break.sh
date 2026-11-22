#!/usr/bin/env bash
# Dynamic breaks inside nested ifs and a nested runtime loop.
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
    echo "72_nested_break: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/72_nested_break.mojo"

"$MOJO" build --emit=circt -o "$out/72_nested_break.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/72_nested_break.mlir" \
    "$out/72_nested_break.mlir"

[ "$(grep -c 'hw.module' "$out/72_nested_break.mlir")" = "3" ]
# Else-with-nested-break: exit path is ~a && b.
grep -q 'comb.and %8, %b : i1' "$out/72_nested_break.mlir"
grep -q 'comb.and %7, %16 : i1' "$out/72_nested_break.mlir"
# Then-with-nested-break: exit path is a && b.
grep -q 'comb.and %a, %b : i1' "$out/72_nested_break.mlir"
grep -q 'comb.and %7, %14 : i1' "$out/72_nested_break.mlir"
# Nested loop: the inner loop exits on a && b and advances the outer.
grep -q 'comb.and %11, %18 : i1' "$out/72_nested_break.mlir"
grep -q 'comb.or %25, %22 : i1' "$out/72_nested_break.mlir"
grep -q 'comb.mux %26, %34, %1 : i64' "$out/72_nested_break.mlir"
grep -q 'seq.compreg %33, %clk reset %rst' "$out/72_nested_break.mlir"
grep -q 'seq.compreg.ce sym @reg_1 %5, %clk, %37' \
    "$out/72_nested_break.mlir"
# The dataflow in each branch runs on the same path as the break.
grep -q 'seq.compreg.ce sym @reg_0 %15, %clk, %13' \
    "$out/72_nested_break.mlir"
grep -q 'seq.compreg.ce sym @reg_0 %13, %clk, %11' \
    "$out/72_nested_break.mlir"
grep -q 'seq.compreg.ce sym @reg_0 %17, %clk, %15' \
    "$out/72_nested_break.mlir"

"$MOJO" build --emit=sv -o "$out/72_nested_break.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/72_nested_break.raw.sv" | grep -v '^$' \
    > "$out/72_nested_break.sv"
diff -u "$root/hdl-spike/expected/72_nested_break.sv" \
    "$out/72_nested_break.sv"

echo "72_nested_break: ok"
