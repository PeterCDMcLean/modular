#!/usr/bin/env bash
# $clog2 in parameter expressions: port widths and state widths.
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
    echo "91_param_clog2: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/91_param_clog2.mojo"

"$MOJO" build --emit=circt -o "$out/91_param_clog2.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/91_param_clog2.mlir" \
    "$out/91_param_clog2.mlir"

# `clog2` maps to hw.param.expr.clog2 in ports and state.
grep -q 'hw.module @ClogPort<W: i32 = 8>' "$out/91_param_clog2.mlir"
grep -q 'hw.module @ClogCounter<W: i32 = 8>' "$out/91_param_clog2.mlir"
! grep -q 'ClogCounter_8\|ClogCounter_32' "$out/91_param_clog2.mlir"
grep -q 'in %a : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>' \
    "$out/91_param_clog2.mlir"
grep -q 'seq.compreg %4, %clk reset %rst, %2 : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>' \
    "$out/91_param_clog2.mlir"
grep -q "sv.verbatim.expr \"(\$clog2(W))'(1)\"" "$out/91_param_clog2.mlir"
grep -q 'hw.instance "small" @ClogCounter<W: i32 = 8>' \
    "$out/91_param_clog2.mlir"
grep -q 'hw.instance "large" @ClogCounter<W: i32 = 32>' \
    "$out/91_param_clog2.mlir"

"$MOJO" build --emit=sv -o "$out/91_param_clog2.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/91_param_clog2.raw.sv" | grep -v '^$' \
    > "$out/91_param_clog2.sv"
diff -u "$root/hdl-spike/expected/91_param_clog2.sv" \
    "$out/91_param_clog2.sv"

sv="$out/91_param_clog2.sv"
grep -q '^module ClogPort$' "$sv"
grep -q 'input  wire \[\$clog2(\$unsigned(W)) - 1:0\] a' "$sv"
grep -q '^module ClogCounter$' "$sv"
grep -q '^  #(parameter W = 8) ($' "$sv"
grep -q 'wire \[\$clog2(\$unsigned(W)) - 1:0\] _GEN;' "$sv"
grep -q "_GEN_0 <= (\$clog2(W))'(0);" "$sv"
grep -q "assign _GEN = _GEN_0 + (\$clog2(W))'(1);" "$sv"
grep -q '^  ClogCounter small_0 ($' "$sv"
grep -q '^    .W(32)$' "$sv"

echo "91_param_clog2: ok"
