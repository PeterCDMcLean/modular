#!/usr/bin/env bash
# Stage 0: hand-written CIRCT survives the compiler's parse/print path.
#
# CIRCT is now registered in the compiler: custom `hw.module` syntax parses and
# prints canonically. The generic-syntax fixture also still round-trips.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KGEN="${KGEN:-$root/bazel-bin/Mojo/tools/kgen/kgen}"
CIRCT_OPT="${CIRCT_OPT:-$HOME/circt/build/bin/circt-opt}"
out="$root/hdl-spike/build"

mkdir -p "$out"

for name in 00_hw_module 00_roundtrip; do
  "$KGEN" --emit=circt "$root/hdl-spike/hand/$name.mlir" \
      > "$out/$name.generic.mlir"

  grep -q 'hw\.' "$out/$name.generic.mlir"
  grep -q 'comb\.' "$out/$name.generic.mlir"

  # Normalize both through circt-opt so module wrappers and SSA names (which
  # the printer is free to choose) do not mask a semantic difference.
  "$CIRCT_OPT" "$out/$name.generic.mlir" -o "$out/$name.actual.mlir"
  "$CIRCT_OPT" "$root/hdl-spike/hand/$name.mlir" -o "$out/$name.expected.mlir"
  diff -u "$out/$name.expected.mlir" "$out/$name.actual.mlir"
done

echo "00b_roundtrip: ok"
