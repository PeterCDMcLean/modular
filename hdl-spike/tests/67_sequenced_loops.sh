#!/usr/bin/env bash
# Sequenced runtime loops: the second loop starts on the first loop's done.
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
    echo "67_sequenced_loops: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/67_sequenced_loops.mojo"

"$MOJO" build --emit=circt -o "$out/67_sequenced_loops.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/67_sequenced_loops.mlir" \
    "$out/67_sequenced_loops.mlir"

[ "$(grep -c 'hw.module' "$out/67_sequenced_loops.mlir")" = "2" ]
# First-loop done, second-loop started flag, second-loop done.
[ "$(grep -c 'seq.compreg %40, %clk reset %rst' "$out/67_sequenced_loops.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg %94, %clk reset %rst' "$out/67_sequenced_loops.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg %93, %clk reset %rst' "$out/67_sequenced_loops.mlir")" = "2" ]
# The second loop body runs on started && in-range, not on the start pulse.
grep -q 'comb.and %47, %48 : i1' "$out/67_sequenced_loops.mlir"
# Writes from the two loops combine per entry.
[ "$(grep -c 'comb.or %13, %52 : i1' "$out/67_sequenced_loops.mlir")" = "2" ]
# Post-loop state is gated by the second loop's done.
[ "$(grep -c 'seq.compreg.ce sym @reg_2 %100, %clk, %98' \
    "$out/67_sequenced_loops.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/67_sequenced_loops.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/67_sequenced_loops.raw.sv" | grep -v '^$' \
    > "$out/67_sequenced_loops.sv"
diff -u "$root/hdl-spike/expected/67_sequenced_loops.sv" \
    "$out/67_sequenced_loops.sv"

# started next = firstDone | (~secondLast & started)
[ "$(grep -c 'assign _GEN_0 = _GEN_16 | ~_GEN_21 & _GEN_18;' \
    "$out/67_sequenced_loops.sv")" = "2" ]
[ "$(grep -c 'else if (_GEN_22)' "$out/67_sequenced_loops.sv")" = "2" ]

echo "67_sequenced_loops: ok"
