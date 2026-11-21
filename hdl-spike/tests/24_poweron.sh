#!/usr/bin/env bash
# Explicit power-on marker is independent of the constructor reset value.
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
    echo "24_poweron: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/24_poweron.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/24_poweron.mojo"
diff -u "$root/hdl-spike/expected/24_poweron.mlir" "$out/24_poweron.mlir"
grep -q 'reset %rst, %c5_i8' "$out/24_poweron.mlir"
grep -q '%c9_i8 = hw.constant 9' "$out/24_poweron.mlir"
grep -q 'initial %0' "$out/24_poweron.mlir"

"$MOJO" build --emit=sv -o "$out/24_poweron.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/24_poweron.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/24_poweron.raw.sv" \
    | grep -v '^$' > "$out/24_poweron.sv"
diff -u "$root/hdl-spike/expected/24_poweron.sv" "$out/24_poweron.sv"
grep -q '_GEN_0 = 8.h9;' "$out/24_poweron.sv"
grep -q '_GEN_0 <= 8.h5;' "$out/24_poweron.sv"

echo "24_poweron: ok"
