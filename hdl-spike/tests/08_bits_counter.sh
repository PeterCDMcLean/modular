#!/usr/bin/env bash
# Bits[W] state: a Bits[12] field lowers to a 12-bit seq.compreg.
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
    echo "08_bits_counter: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/08_bits_counter.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/08_bits_counter.mojo"
diff -u "$root/hdl-spike/expected/08_bits_counter.mlir" "$out/08_bits_counter.mlir"
grep -q 'seq.compreg' "$out/08_bits_counter.mlir"
grep -q 'i12' "$out/08_bits_counter.mlir"

"$MOJO" build --emit=sv -o "$out/08_bits_counter.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/08_bits_counter.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/08_bits_counter.raw.sv" \
    | grep -v '^$' > "$out/08_bits_counter.sv"
diff -u "$root/hdl-spike/expected/08_bits_counter.sv" "$out/08_bits_counter.sv"
grep -q 'always @(posedge clk)' "$out/08_bits_counter.sv"
grep -q 'output \[11:0\] out' "$out/08_bits_counter.sv"

echo "08_bits_counter: ok"
