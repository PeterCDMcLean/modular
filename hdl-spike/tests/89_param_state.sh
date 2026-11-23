#!/usr/bin/env bash
# Stateful RTL parameters: Bits[W] and Reg[Bits[W]] state stay symbolic.
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
    echo "89_param_state: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/89_param_state.mojo"

"$MOJO" build --emit=circt -o "$out/89_param_state.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/89_param_state.mlir" \
    "$out/89_param_state.mlir"

# One generic stateful module with a default; state types and reset constants
# are parameter expressions.
grep -q 'hw.module @ParamAccumulator<W: i32 = 8>' "$out/89_param_state.mlir"
! grep -q 'ParamAccumulator_8\|ParamAccumulator_16' "$out/89_param_state.mlir"
grep -q 'seq.compreg %1, %clk reset %rst, %W_0 : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/89_param_state.mlir"
grep -q 'seq.compreg %3, %clk reset %rst, %W_2 : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/89_param_state.mlir"
grep -q 'comb.add %0, %step : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/89_param_state.mlir"
grep -q 'comb.xor %0, %2 : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/89_param_state.mlir"
grep -q '#hw.param.verbatim' "$out/89_param_state.mlir" || true
grep -q "sv.verbatim.expr \"W'(1)\"" "$out/89_param_state.mlir"
grep -q 'hw.instance "narrow" @ParamAccumulator<W: i32 = 8>' \
    "$out/89_param_state.mlir"
grep -q 'hw.instance "wide" @ParamAccumulator<W: i32 = 16>' \
    "$out/89_param_state.mlir"

"$MOJO" build --emit=sv -o "$out/89_param_state.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/89_param_state.raw.sv" | grep -v '^$' \
    > "$out/89_param_state.sv"
diff -u "$root/hdl-spike/expected/89_param_state.sv" \
    "$out/89_param_state.sv"

sv="$out/89_param_state.sv"
grep -q '^module ParamAccumulator$' "$sv"
grep -q '^  #(parameter W = 8) ($' "$sv"
grep -q 'input  wire \[W - 1:0\] step' "$sv"
grep -q 'output wire \[W - 1:0\] out' "$sv"
grep -q "_GEN_1 <= W'(0);" "$sv"
grep -q "_GEN_2 <= W'(1);" "$sv"
grep -q "assign _GEN = _GEN_2 + W'(1);" "$sv"
grep -q 'assign out = _GEN_1 ^ _GEN_2;' "$sv"
grep -q '^  ParamAccumulator narrow ($' "$sv"
grep -q '^    .W(16)$' "$sv"

echo "89_param_state: ok"
