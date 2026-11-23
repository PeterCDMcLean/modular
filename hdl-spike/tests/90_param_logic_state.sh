#!/usr/bin/env bash
# Stateful RTL parameters for 4-state state: Logic[W] value and mask registers.
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
    echo "90_param_logic_state: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/90_param_logic_state.mojo"

"$MOJO" build --emit=circt -o "$out/90_param_logic_state.mlir" \
    "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/90_param_logic_state.mlir" \
    "$out/90_param_logic_state.mlir"

# One generic module: both the value and mask registers stay symbolic.
grep -q 'hw.module @ParamLogicState<W: i32 = 8>' \
    "$out/90_param_logic_state.mlir"
! grep -q 'ParamLogicState_8\|ParamLogicState_16' \
    "$out/90_param_logic_state.mlir"
grep -q 'in %d_xz : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/90_param_logic_state.mlir"
grep -q 'out out_xz : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/90_param_logic_state.mlir"
grep -q 'seq.compreg %8, %clk reset %rst, %W_0 : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/90_param_logic_state.mlir"
grep -q 'seq.compreg %6, %clk reset %rst, %W_2 : !hw.int<#hw.param.decl.ref<"W">>' \
    "$out/90_param_logic_state.mlir"
grep -q "sv.verbatim.expr \"W'(-1)\"" "$out/90_param_logic_state.mlir"
grep -q 'hw.instance "narrow" @ParamLogicState<W: i32 = 8>' \
    "$out/90_param_logic_state.mlir"
grep -q 'hw.instance "wide" @ParamLogicState<W: i32 = 16>' \
    "$out/90_param_logic_state.mlir"

"$MOJO" build --emit=sv -o "$out/90_param_logic_state.raw.sv" \
    "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/90_param_logic_state.raw.sv" | grep -v '^$' \
    > "$out/90_param_logic_state.sv"
diff -u "$root/hdl-spike/expected/90_param_logic_state.sv" \
    "$out/90_param_logic_state.sv"

sv="$out/90_param_logic_state.sv"
grep -q '^module ParamLogicState$' "$sv"
grep -q '^  #(parameter W = 8) ($' "$sv"
grep -q 'input  wire \[W - 1:0\] d_xz' "$sv"
grep -q 'output wire \[W - 1:0\] out_xz' "$sv"
grep -q "_GEN_1 <= W'(0);" "$sv"
grep -q "_GEN_2 <= W'(0);" "$sv"
grep -q "assign _GEN = _GEN_1 & d ^ W'(-1);" "$sv"
grep -q '^  ParamLogicState narrow ($' "$sv"
grep -q '^    .W(16)$' "$sv"
grep -q 'input  wire \[7:0\]  n_xz' "$sv"
grep -q 'output wire \[15:0\] run_wide_out_xz' "$sv"

echo "90_param_logic_state: ok"
