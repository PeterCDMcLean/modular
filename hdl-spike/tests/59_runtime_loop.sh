#!/usr/bin/env bash
# Runtime-bounded loops: one iteration per clock (time-multiplexed).
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
    echo "59_runtime_loop: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/59_runtime_loop.mojo"

"$MOJO" build --emit=circt -o "$out/59_runtime_loop.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/59_runtime_loop.mlir" \
    "$out/59_runtime_loop.mlir"

# One 64-bit induction register, an in-range compare, and a wrapped update.
grep -q 'seq.compreg %21, %clk reset %rst' "$out/59_runtime_loop.mlir"
grep -q 'comb.icmp ult %1, %count : i64' "$out/59_runtime_loop.mlir"
grep -q 'comb.mux %2, %20, %c0_i64_9 : i64' "$out/59_runtime_loop.mlir"
# Every memory entry and the state field update only while in range.
grep -q 'comb.and %2, %17 : i1' "$out/59_runtime_loop.mlir"
grep -q 'seq.compreg.ce sym @reg_1 %wd, %clk, %2' \
    "$out/59_runtime_loop.mlir"

"$MOJO" build --emit=sv -o "$out/59_runtime_loop.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/59_runtime_loop.raw.sv" | grep -v '^$' \
    > "$out/59_runtime_loop.sv"
diff -u "$root/hdl-spike/expected/59_runtime_loop.sv" \
    "$out/59_runtime_loop.sv"

grep -q 'wire             _GEN_5 = _GEN_4 < count;' \
    "$out/59_runtime_loop.sv"
grep -q 'assign _GEN_3 = _GEN_5 & en & _GEN_4 == 64.h0;' \
    "$out/59_runtime_loop.sv"
grep -q 'assign _GEN = _GEN_5 ? _GEN_4 + 64.h1 : 64.h0;' \
    "$out/59_runtime_loop.sv"
grep -q 'else if (_GEN_5)' "$out/59_runtime_loop.sv"
# The body is emitted once, not unrolled.
[ "$(grep -c 'var logic \[7:0\]  mem_0_' "$out/59_runtime_loop.sv")" = "4" ]

# A local carried across iterations is not representable yet.
if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/59_bad_runtime_accum.mojo" \
    > "$out/59_bad_runtime_accum.out" 2>&1; then
  echo "FAIL: a loop-carried local was accepted" >&2
  exit 1
fi
grep -q "loop-carried local variable in a runtime-bounded loop" \
    "$out/59_bad_runtime_accum.out"

echo "59_runtime_loop: ok"
