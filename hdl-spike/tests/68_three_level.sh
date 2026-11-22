#!/usr/bin/env bash
# Three-level runtime loop nesting.
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
    echo "68_three_level: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/68_three_level.mojo"

"$MOJO" build --emit=circt -o "$out/68_three_level.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/68_three_level.mlir" \
    "$out/68_three_level.mlir"

[ "$(grep -c 'hw.module' "$out/68_three_level.mlir")" = "1" ]
# Three counters with independent in-range compares.
grep -q 'comb.icmp ult %1, %a : i64' "$out/68_three_level.mlir"
grep -q 'comb.icmp ult %4, %b : i64' "$out/68_three_level.mlir"
grep -q 'comb.icmp ult %8, %c : i64' "$out/68_three_level.mlir"
grep -q 'comb.and %6, %9 : i1' "$out/68_three_level.mlir"
# Completion propagates c -> b -> a, and counters advance accordingly.
grep -q 'comb.and %10, %49 : i1' "$out/68_three_level.mlir"
grep -q 'comb.and %50, %54 : i1' "$out/68_three_level.mlir"
grep -q 'comb.and %55, %59 : i1' "$out/68_three_level.mlir"
grep -q 'comb.mux %50, %56, %4 : i64' "$out/68_three_level.mlir"
grep -q 'comb.mux %55, %61, %1 : i64' "$out/68_three_level.mlir"
grep -q 'seq.compreg %60, %clk reset %rst' "$out/68_three_level.mlir"
grep -q 'seq.compreg.ce sym @reg_2 %66, %clk, %64' \
    "$out/68_three_level.mlir"

"$MOJO" build --emit=sv -o "$out/68_three_level.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/68_three_level.raw.sv" | grep -v '^$' \
    > "$out/68_three_level.sv"
diff -u "$root/hdl-spike/expected/68_three_level.sv" \
    "$out/68_three_level.sv"

[ "$(grep -c 'var logic \[7:0\]  mem_0_' "$out/68_three_level.sv")" = "8" ]
grep -q 'else if (_GEN_' "$out/68_three_level.sv"

echo "68_three_level: ok"
