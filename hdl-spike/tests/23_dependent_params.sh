#!/usr/bin/env bash
# Dependent parameters: width W+E and literal E specialize per binding tuple.
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
    echo "23_dependent_params: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/23_dependent_params.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/23_dependent_params.mojo"
diff -u "$root/hdl-spike/expected/23_dependent_params.mlir" "$out/23_dependent_params.mlir"
grep -q 'hw.module @DepCounter_8_1.*out out : i9' "$out/23_dependent_params.mlir"
grep -q 'hw.module @DepCounter_16_4.*out out : i20' "$out/23_dependent_params.mlir"
grep -q 'comb.add %1, %c1_i9 : i9' "$out/23_dependent_params.mlir"
grep -q 'comb.add %1, %c4_i20 : i20' "$out/23_dependent_params.mlir"

"$MOJO" build --emit=sv -o "$out/23_dependent_params.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/23_dependent_params.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/23_dependent_params.raw.sv" \
    | grep -v '^$' > "$out/23_dependent_params.sv"
diff -u "$root/hdl-spike/expected/23_dependent_params.sv" "$out/23_dependent_params.sv"
grep -q 'output wire \[8:0\] out' "$out/23_dependent_params.sv"
grep -q 'output wire \[19:0\] out' "$out/23_dependent_params.sv"

echo "23_dependent_params: ok"
