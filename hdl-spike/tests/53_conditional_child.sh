#!/usr/bin/env bash
# Conditional effects: one stateful child ticked from exclusive branches.
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
    echo "53_conditional_child: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/53_conditional_child.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/53_conditional_child.mojo"
diff -u "$root/hdl-spike/expected/53_conditional_child.mlir" \
    "$out/53_conditional_child.mlir"

# One instance per module, even though each branch ticks it.
[[ "$(grep -c 'hw.instance "cell" @AccCell' "$out/53_conditional_child.mlir")" == 2 ]]
grep -q 'hw.module @ConditionalTick' "$out/53_conditional_child.mlir"
grep -q 'comb.mux %3, %b, %a : i8' "$out/53_conditional_child.mlir"
grep -q 'comb.mux %sel, %cell.out, %c0_i8 : i8' \
    "$out/53_conditional_child.mlir"
grep -q 'comb.and %3, %sel_b : i1' "$out/53_conditional_child.mlir"
grep -q 'comb.mux %9, %c, %5 : i8' "$out/53_conditional_child.mlir"

"$MOJO" build --emit=sv -o "$out/53_conditional_child.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/53_conditional_child.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/53_conditional_child.raw.sv" | grep -v '^$' \
    > "$out/53_conditional_child.sv"
diff -u "$root/hdl-spike/expected/53_conditional_child.sv" \
    "$out/53_conditional_child.sv"
grep -q 'AccCell cell_0 (' "$out/53_conditional_child.sv"
grep -q 'assign _GEN = ~sel ? b : a;' "$out/53_conditional_child.sv"
# Both branches tick, so the merged result is the child output every cycle.
grep -q '_GEN_0 <= _cell_out;' "$out/53_conditional_child.sv"

# Overlapping conditional ticks are still a real double tick.
if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/53_bad_parallel_tick.mojo" \
    > "$out/53_bad_parallel_tick.out" 2>&1; then
  echo "FAIL: overlapping conditional ticks were accepted" >&2
  exit 1
fi
grep -q "instance 'cell' is ticked more than once in process 'run' (branches are not mutually exclusive)" \
    "$out/53_bad_parallel_tick.out"

echo "53_conditional_child: ok"
