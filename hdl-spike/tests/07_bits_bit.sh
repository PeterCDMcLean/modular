#!/usr/bin/env bash
# Bits[W] bit select with a constant index becomes comb.extract.
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
    echo "07_bits_bit: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/07_bits_bit.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/07_bits_bit.mojo"
diff -u "$root/hdl-spike/expected/07_bits_bit.mlir" "$out/07_bits_bit.mlir"
grep -q 'comb.extract %a from 3' "$out/07_bits_bit.mlir"

"$MOJO" build --emit=sv -o "$out/07_bits_bit.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/07_bits_bit.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/07_bits_bit.raw.sv" \
    | grep -v '^$' > "$out/07_bits_bit.sv"
diff -u "$root/hdl-spike/expected/07_bits_bit.sv" "$out/07_bits_bit.sv"
grep -q 'assign out = a\[3\];' "$out/07_bits_bit.sv"

echo "07_bits_bit: ok"
