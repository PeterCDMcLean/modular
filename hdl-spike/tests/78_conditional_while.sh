#!/usr/bin/env bash
# Carried while loops with conditional sequences and breaks.
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
    echo "78_conditional_while: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/78_conditional_while.mojo"

"$MOJO" build --emit=circt -o "$out/78_conditional_while.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/78_conditional_while.mlir" \
    "$out/78_conditional_while.mlir"

[ "$(grep -c 'hw.module' "$out/78_conditional_while.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/78_conditional_while.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/78_conditional_while.raw.sv" | grep -v '^$' \
    > "$out/78_conditional_while.sv"
diff -u "$root/hdl-spike/expected/78_conditional_while.sv" \
    "$out/78_conditional_while.sv"

# WhileConditionalCarry: the unconditional add composes with the branch
# add, and the else add composes on top of the shared update.
grep -q '_GEN_6 ? _GEN_5 + wd : _GEN_5;' \
    "$out/78_conditional_while.sv"
grep -q '_GEN_6 & a ? _GEN_7 + 8.h1 : _GEN_7;' \
    "$out/78_conditional_while.sv"
grep -q 'assign _GEN_2 = _GEN_4 ? (_GEN_6 & ~a ? _GEN_8 + 8.h2 : _GEN_8) : 8.h0;' \
    "$out/78_conditional_while.sv"
# The nested break exits on the full path and drives the done pulse.
grep -q 'wire             _GEN_10 = _GEN_6 & a & b;' \
    "$out/78_conditional_while.sv"
grep -q 'wire             _GEN_11 = _GEN_6 & _GEN_9 == count | _GEN_10;' \
    "$out/78_conditional_while.sv"
grep -q 'assign _GEN_1 = _GEN_6 ? (_GEN_10 ? count : _GEN_9) : 64.h0;' \
    "$out/78_conditional_while.sv"
# Post-loop fields sample the final accumulator on the done pulse.
grep -q 'else if (_GEN_12)' "$out/78_conditional_while.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/78_conditional_while.sv"

# LogicWhileConditional: both conditional updates compose on the carried
# value and mask pair, and the nested break uses a && b.
grep -q 'wire             _GEN_11 = _GEN_10 & a;' \
    "$out/78_conditional_while.sv"
grep -q '{8{_GEN_11}} & wd | _GEN_8;' \
    "$out/78_conditional_while.sv"
grep -q 'wire             _GEN_14 = _GEN_10 & ~a;' \
    "$out/78_conditional_while.sv"
grep -q '({8{~_GEN_14}} | wd) & _GEN_12 : wd;' \
    "$out/78_conditional_while.sv"
grep -q 'wire             _GEN_16 = _GEN_10 & a & b;' \
    "$out/78_conditional_while.sv"
grep -q 'assign _GEN_3 = _GEN_10 ? (_GEN_16 ? count : _GEN_15) : 64.h0;' \
    "$out/78_conditional_while.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/78_conditional_while.sv"

echo "78_conditional_while: ok"
