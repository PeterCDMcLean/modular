#!/usr/bin/env bash
# User-defined parameter-time function with if/else flow control.
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
    echo "87_param_function_flow: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/87_param_function_flow.mojo"

"$MOJO" build --emit=circt -o "$out/87_param_function_flow.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/87_param_function_flow.mlir" \
    "$out/87_param_function_flow.mlir"

grep -q '#hw.param.verbatim<"hdl_clamp(W, 16, 64)">' \
    "$out/87_param_function_flow.mlir"

"$MOJO" build --emit=sv -o "$out/87_param_function_flow.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/87_param_function_flow.raw.sv" | grep -v '^$' \
    > "$out/87_param_function_flow.sv"
diff -u "$root/hdl-spike/expected/87_param_function_flow.sv" \
    "$out/87_param_function_flow.sv"

grep -q 'function automatic integer hdl_clamp(input integer a0, input integer a1, input integer a2);' \
    "$out/87_param_function_flow.sv"
grep -q 'if ((a0 < a1)) begin' "$out/87_param_function_flow.sv"
grep -q 'return a1;' "$out/87_param_function_flow.sv"
grep -q 'if ((a0 > a2)) begin' "$out/87_param_function_flow.sv"
grep -q 'return a2;' "$out/87_param_function_flow.sv"
grep -q 'return a0;' "$out/87_param_function_flow.sv"
grep -q 'input  wire \[hdl_clamp(W, 16, 64) - 1:0\] a' \
    "$out/87_param_function_flow.sv"

echo "87_param_function_flow: ok"
