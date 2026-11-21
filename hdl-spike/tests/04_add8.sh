#!/usr/bin/env bash
# Stage 3: primitive 8-bit add lowers to comb.add and exports SV.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
out="$root/hdl-spike/build"
inc=(-I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike")

mkdir -p "$out"

"$MOJO" build --emit=circt -o "$out/03_add8.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/03_add8.mojo"
diff -u "$root/hdl-spike/expected/03_add8.mlir" "$out/03_add8.mlir"

"$MOJO" build --emit=sv -o "$out/03_add8.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/03_add8.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/03_add8.raw.sv" \
    | grep -v '^$' > "$out/03_add8.sv"
diff -u "$root/hdl-spike/expected/03_add8.sv" "$out/03_add8.sv"

echo "04_add8: ok"
