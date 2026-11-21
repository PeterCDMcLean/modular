#!/usr/bin/env bash
# Bits[W] at the port boundary: any-width arithmetic/bitwise ops become comb.
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
    echo "06_bits_ops: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/06_bits_ops.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/06_bits_ops.mojo"
diff -u "$root/hdl-spike/expected/06_bits_ops.mlir" "$out/06_bits_ops.mlir"
grep -q 'comb.add\|comb.sub' "$out/06_bits_ops.mlir"
grep -q 'comb.and' "$out/06_bits_ops.mlir"
grep -q 'i12' "$out/06_bits_ops.mlir"

"$MOJO" build --emit=sv -o "$out/06_bits_ops.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/06_bits_ops.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/06_bits_ops.raw.sv" \
    | grep -v '^$' > "$out/06_bits_ops.sv"
diff -u "$root/hdl-spike/expected/06_bits_ops.sv" "$out/06_bits_ops.sv"
grep -q '\[11:0\] a' "$out/06_bits_ops.sv"

echo "06_bits_ops: ok"
