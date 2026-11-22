#!/usr/bin/env bash
# Runtime-bounded `for i in range(n)`: one iteration per clock.
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
    echo "60_runtime_range: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/60_runtime_range.mojo"

"$MOJO" build --emit=circt -o "$out/60_runtime_range.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/60_runtime_range.mlir" \
    "$out/60_runtime_range.mlir"

# The range iterator is replaced by a counter, an in-range compare, and a
# wrapped update.
grep -q 'seq.compreg %23, %clk reset %rst' "$out/60_runtime_range.mlir"
grep -q 'comb.icmp ult %1, %count : i64' "$out/60_runtime_range.mlir"
grep -q 'comb.mux %2, %20, %c0_i64_9 : i64' "$out/60_runtime_range.mlir"
grep -q 'seq.compreg.ce sym @reg_1 %wd, %clk, %2' \
    "$out/60_runtime_range.mlir"
if grep -q 'seq.hlmem\|firmem' "$out/60_runtime_range.mlir"; then
  echo "FAIL: unexpected memory lowering" >&2
  exit 1
fi

"$MOJO" build --emit=sv -o "$out/60_runtime_range.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/60_runtime_range.raw.sv" | grep -v '^$' \
    > "$out/60_runtime_range.sv"
grep -q 'assign _GEN = _GEN_5 ? _GEN_6 : 64.h0;' \
    "$out/60_runtime_range.sv"
diff -u "$root/hdl-spike/expected/60_runtime_range.sv" \
    "$out/60_runtime_range.sv"

grep -q 'wire             _GEN_5 = _GEN_4 < count;' \
    "$out/60_runtime_range.sv"
grep -q 'assign _GEN_3 = _GEN_5 & en & _GEN_4 == 64.h0;' \
    "$out/60_runtime_range.sv"
grep -q 'wire      \[63:0\] _GEN_6 = _GEN_4 + 64.h1;' \
    "$out/60_runtime_range.sv"
[ "$(grep -c 'var logic \[7:0\]  mem_0_' "$out/60_runtime_range.sv")" = "4" ]

echo "60_runtime_range: ok"
