#!/usr/bin/env bash
# Looped process effects: constant-bounded loops are unrolled.
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
    echo "56_loop_effects: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/56_loop_effects.mojo"

"$MOJO" build --emit=circt -o "$out/56_loop_effects.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/56_loop_effects.mlir" \
    "$out/56_loop_effects.mlir"

# Four loop iterations are four adds in both the range loop and the while
# loop.
grep -q 'hw.module @LoopSum' "$out/56_loop_effects.mlir"
grep -q 'hw.module @WhileSum' "$out/56_loop_effects.mlir"
[ "$(grep -c 'comb.add %a, %b' "$out/56_loop_effects.mlir")" = "2" ]
grep -q 'comb.add %0, %b' "$out/56_loop_effects.mlir"
grep -q 'comb.add %1, %b' "$out/56_loop_effects.mlir"
grep -q 'comb.add %2, %b' "$out/56_loop_effects.mlir"
# The memory loop writes every entry once.
[ "$(grep -c 'seq.compreg.ce sym @mem_0_' "$out/56_loop_effects.mlir")" = "4" ]
grep -q 'sym @mem_0_0' "$out/56_loop_effects.mlir"
grep -q 'sym @mem_0_3' "$out/56_loop_effects.mlir"
# A tick guarded by the induction variable is emitted once.
[ "$(grep -c 'hw.instance "cell" @AccCell' "$out/56_loop_effects.mlir")" = "1" ]
grep -q 'seq.compreg %cell.out' "$out/56_loop_effects.mlir"

"$MOJO" build --emit=sv -o "$out/56_loop_effects.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/56_loop_effects.raw.sv" | grep -v '^$' \
    > "$out/56_loop_effects.sv"
diff -u "$root/hdl-spike/expected/56_loop_effects.sv" \
    "$out/56_loop_effects.sv"

grep -q 'assign out = a + {b\[5:0\], 2.h0};' "$out/56_loop_effects.sv"
[ "$(grep -c 'else if (en)' "$out/56_loop_effects.sv")" = "4" ]
grep -q 'mem_0_3 <= wd;' "$out/56_loop_effects.sv"
grep -q 'assign out = mem_0_2;' "$out/56_loop_effects.sv"
grep -q 'AccCell cell_0 (' "$out/56_loop_effects.sv"
grep -q '_GEN <= _cell_out;' "$out/56_loop_effects.sv"

# A stateful child may not tick on every iteration: that is multiple ticks per
# clock, not a loop-carried effect.
if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/56_bad_loop_tick.mojo" \
    > "$out/56_bad_loop_tick.out" 2>&1; then
  echo "FAIL: a child ticked every loop iteration was accepted" >&2
  exit 1
fi
grep -q "instance 'cell' is ticked more than once in process 'run' (branches are not mutually exclusive)" \
    "$out/56_bad_loop_tick.out"

echo "56_loop_effects: ok"
