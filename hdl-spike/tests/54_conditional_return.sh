#!/usr/bin/env bash
# Conditional returns: method results are muxed over branch conditions.
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
    echo "54_conditional_return: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/54_conditional_return.mojo"

"$MOJO" build --emit=circt -o "$out/54_conditional_return.mlir" "${inc[@]}" \
    "$design"
diff -u "$root/hdl-spike/expected/54_conditional_return.mlir" \
    "$out/54_conditional_return.mlir"

grep -q 'hw.module @ReturnMux(in %sel : i1, in %a : i8, in %b : i8, out out : i8)' \
    "$out/54_conditional_return.mlir"
grep -q 'hw.module @ReturnFallthrough' "$out/54_conditional_return.mlir"
grep -q 'hw.module @LogicReturn' "$out/54_conditional_return.mlir"
grep -q 'comb.mux %sel, %a, %b : i8' "$out/54_conditional_return.mlir"
grep -q 'comb.mux %sel, %a_xz, %b_xz : i8' \
    "$out/54_conditional_return.mlir"
grep -q 'comb.mux %sel, %0, %3 : i8' "$out/54_conditional_return.mlir"
[[ "$(grep -c 'hw.instance "cell" @AccCell' "$out/54_conditional_return.mlir")" == 1 ]]

"$MOJO" build --emit=sv -o "$out/54_conditional_return.raw.sv" "${inc[@]}" \
    "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/54_conditional_return.raw.sv" | grep -v '^$' \
    > "$out/54_conditional_return.sv"
diff -u "$root/hdl-spike/expected/54_conditional_return.sv" \
    "$out/54_conditional_return.sv"

# Both conditional-return modules collapse to one mux in SystemVerilog.
[[ "$(grep -c 'assign out = sel ? a : b;' "$out/54_conditional_return.sv")" -ge 2 ]]
grep -q 'assign out_xz = sel ? a_xz : b_xz;' \
    "$out/54_conditional_return.sv"
# The instance-result path ends at the child output once branches are merged.
grep -q '\.out   (out)' "$out/54_conditional_return.sv"
grep -q 'assign _GEN = ~sel ? b : a;' "$out/54_conditional_return.sv"

echo "54_conditional_return: ok"
