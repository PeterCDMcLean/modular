#!/usr/bin/env bash
# Parameter-time SystemVerilog function lowering.
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
    echo "86_param_function: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/86_param_function.mojo"

"$MOJO" build --emit=circt -o "$out/86_param_function.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/86_param_function.mlir" \
    "$out/86_param_function.mlir"

# The width expression is opaque parameter-time text, not a 2-state value.
grep -q '#hw.param.verbatim<"hdl_max(W, 16)">' \
    "$out/86_param_function.mlir"
grep -q 'hw.module @MaxWidth<W: i32 = 8>' "$out/86_param_function.mlir"

"$MOJO" build --emit=sv -o "$out/86_param_function.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/86_param_function.raw.sv" | grep -v '^$' \
    > "$out/86_param_function.sv"
diff -u "$root/hdl-spike/expected/86_param_function.sv" \
    "$out/86_param_function.sv"

# A helper SV function is generated once, before the module, and used in the
# parameter-dependent port width.
grep -q 'function automatic integer hdl_max(input integer a, input integer b);' \
    "$out/86_param_function.sv"
grep -q 'return (a > b) ? a : b;' "$out/86_param_function.sv"
grep -q 'endfunction' "$out/86_param_function.sv"
grep -q '#(parameter W = 8)' "$out/86_param_function.sv"
grep -q 'input  wire \[hdl_max(W, 16) - 1:0\] a' \
    "$out/86_param_function.sv"
grep -q 'output wire \[hdl_max(W, 16) - 1:0\] out' \
    "$out/86_param_function.sv"

echo "86_param_function: ok"
