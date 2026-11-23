#!/usr/bin/env bash
# Compile-time parameters emitted as real SystemVerilog module parameters.
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
    echo "85_rtl_params: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/85_rtl_params.mojo"

"$MOJO" build --emit=circt -o "$out/85_rtl_params.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/85_rtl_params.mlir" \
    "$out/85_rtl_params.mlir"

# One generic module per parameterized struct, not one per binding tuple.
grep -q 'hw.module @Passthrough<W: i32 = 8>' "$out/85_rtl_params.mlir"
grep -q 'hw.module @Scaled<W: i32 = 8>' "$out/85_rtl_params.mlir"
! grep -q 'Passthrough_8\|Passthrough_16' "$out/85_rtl_params.mlir"
! grep -q 'Scaled_8\|Scaled_16' "$out/85_rtl_params.mlir"

# Port widths stay symbolic.
grep -q '!hw.int<#hw.param.decl.ref<"W">>' "$out/85_rtl_params.mlir"
grep -q '#hw.param.expr.add<#hw.param.decl.ref<"W">, 1>' \
    "$out/85_rtl_params.mlir"

# Each instance supplies its own parameter values.
grep -q 'hw.instance "narrow" @Passthrough<W: i32 = 8>' \
    "$out/85_rtl_params.mlir"
grep -q 'hw.instance "wide" @Passthrough<W: i32 = 16>' \
    "$out/85_rtl_params.mlir"
grep -q 'hw.instance "small" @Scaled<W: i32 = 8>' \
    "$out/85_rtl_params.mlir"
grep -q 'hw.instance "large" @Scaled<W: i32 = 16>' \
    "$out/85_rtl_params.mlir"

"$MOJO" build --emit=sv -o "$out/85_rtl_params.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/85_rtl_params.raw.sv" | grep -v '^$' \
    > "$out/85_rtl_params.sv"
diff -u "$root/hdl-spike/expected/85_rtl_params.sv" \
    "$out/85_rtl_params.sv"

# SystemVerilog module parameters (with defaults) and parameterized ports.
grep -q '#(parameter W = 8)' "$out/85_rtl_params.sv"
grep -q 'input  wire \[W - 1:0\] a' "$out/85_rtl_params.sv"
grep -q 'input  wire \[W:0\] a' "$out/85_rtl_params.sv"
# Instances equal to the default omit the override; the others pass it.
grep -q '^  Passthrough narrow ($' "$out/85_rtl_params.sv"
grep -q '^  Scaled small_0 ($' "$out/85_rtl_params.sv"
grep -q '^    .W(16)$' "$out/85_rtl_params.sv"
grep -q 'Passthrough #(' "$out/85_rtl_params.sv"
grep -q 'Scaled #(' "$out/85_rtl_params.sv"

echo "85_rtl_params: ok"
