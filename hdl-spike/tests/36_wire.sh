#!/usr/bin/env bash
# Typed Wire: a combinational field lowered to an SSA net.
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
    echo "36_wire: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/36_wire.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/36_wire.mojo"
diff -u "$root/hdl-spike/expected/36_wire.mlir" "$out/36_wire.mlir"
grep -q 'comb.xor %a, %b' "$out/36_wire.mlir"
if grep -q 'seq.compreg\|seq.firreg\|!seq.clock' "$out/36_wire.mlir"; then
  echo "FAIL: a Wire must not create state or a clock" >&2
  exit 1
fi

"$MOJO" build --emit=sv -o "$out/36_wire.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/36_wire.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/36_wire.raw.sv" \
    | grep -v '^$' > "$out/36_wire.sv"
diff -u "$root/hdl-spike/expected/36_wire.sv" "$out/36_wire.sv"
grep -q 'assign out = a \^ b;' "$out/36_wire.sv"
if grep -q 'always' "$out/36_wire.sv"; then
  echo "FAIL: a Wire module must be purely combinational" >&2
  exit 1
fi

echo "36_wire: ok"
