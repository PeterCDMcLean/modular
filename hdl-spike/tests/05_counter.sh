#!/usr/bin/env bash
# Stage 4: a struct field becomes a seq.compreg with clk, reset, and power-on.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
out="$root/hdl-spike/build"
inc=(-I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike")

mkdir -p "$out"

"$MOJO" build --emit=circt -o "$out/04_counter.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/04_counter.mojo"
diff -u "$root/hdl-spike/expected/04_counter.mlir" "$out/04_counter.mlir"
grep -q 'seq.compreg' "$out/04_counter.mlir"

"$MOJO" build --emit=sv -o "$out/04_counter.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/04_counter.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/04_counter.raw.sv" \
    | grep -v '^$' > "$out/04_counter.sv"
diff -u "$root/hdl-spike/expected/04_counter.sv" "$out/04_counter.sv"
grep -q 'always @(posedge clk)' "$out/04_counter.sv"

echo "05_counter: ok"
