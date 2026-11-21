#!/usr/bin/env bash
# Stage 1: `--emit=circt` runs the HDL pass at the post-elaboration hook and
# can print the KGEN IR it consumed.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
KGEN="${KGEN:-$root/bazel-bin/Mojo/tools/kgen/kgen}"
out="$root/hdl-spike/build"
# The source build has no installed Mojo config: point at the freshly built
# stdlib package and at the hdl-spike DSL package explicitly.

mkdir -p "$out"

MOJO_HDL_DUMP_IR=1 "$MOJO" build --emit=circt -o "$out/01_inv.dump.mlir" \
    -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/01_inv.mojo"

# The dump is KGEN IR: method symbol present, no lowered hw.module yet.
grep -q 'Inv::run' "$out/01_inv.dump.mlir"
if grep -q 'hw\.module' "$out/01_inv.dump.mlir"; then
  echo "FAIL: dump should precede the HDL lowering" >&2
  exit 1
fi

# The kgen tool exposes the same hook explicitly.
"$KGEN" --emit=circt --hdl-dump-ir \
    -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/01_inv.mojo" > "$out/01_inv.kgen.dump.mlir"
grep -q 'Inv::run' "$out/01_inv.kgen.dump.mlir"

# The same hook on a stateful design: the field and both methods survive to the
# KGEN IR the pass consumes.
"$KGEN" --emit=circt --hdl-dump-ir \
    -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/02_stateful_dump.mojo" \
    > "$out/02_stateful.dump.mlir"
grep -q 'Stateful::run' "$out/02_stateful.dump.mlir"
grep -q 'Stateful' "$out/02_stateful.dump.mlir"

echo "01_dump: ok"
