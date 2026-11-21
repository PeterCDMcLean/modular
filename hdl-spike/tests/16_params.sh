#!/usr/bin/env bash
# Parameters/generate: one generic module specialized at two widths.
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
    echo "16_params: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/16_params.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/16_params.mojo"
diff -u "$root/hdl-spike/expected/16_params.mlir" "$out/16_params.mlir"
grep -q 'hw.module @ParamCounter_8' "$out/16_params.mlir"
grep -q 'hw.module @ParamCounter_16' "$out/16_params.mlir"
grep -q 'hw.instance "narrow" @ParamCounter_8' "$out/16_params.mlir"
grep -q 'hw.instance "wide" @ParamCounter_16' "$out/16_params.mlir"

"$MOJO" build --emit=sv -o "$out/16_params.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/16_params.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/16_params.raw.sv" \
    | grep -v '^$' > "$out/16_params.sv"
diff -u "$root/hdl-spike/expected/16_params.sv" "$out/16_params.sv"
grep -q 'module ParamCounter_8' "$out/16_params.sv"
grep -q 'module ParamCounter_16' "$out/16_params.sv"
grep -q 'ParamCounter_8 narrow' "$out/16_params.sv"
grep -q 'ParamCounter_16 wide' "$out/16_params.sv"

echo "16_params: ok"
