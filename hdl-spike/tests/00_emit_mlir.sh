#!/usr/bin/env bash
# Stage 0: `--emit=mlir` prints the compiler's own module (not a text emitter).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
out="$root/hdl-spike/build"
# The source build has no installed Mojo config: point at the freshly built
# stdlib package and at the hdl-spike DSL package explicitly.

mkdir -p "$out"

# A trivial Mojo program: the printed module must be the compiler's own KGEN IR.
"$MOJO" build --emit=mlir -o "$out/00_hello.mlir" \
    -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/00_hello.mojo"

grep -q 'kgen.func' "$out/00_hello.mlir"
grep -q '@main' "$out/00_hello.mlir"
if grep -q 'hw\.module' "$out/00_hello.mlir"; then
  echo "FAIL: --emit=mlir must not contain CIRCT ops" >&2
  exit 1
fi

echo "00_emit_mlir: ok"
