#!/usr/bin/env bash
# Loop-carried state in runtime loops becomes explicit registers.
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
    echo "62_loop_carried: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/62_loop_carried.mojo"

"$MOJO" build --emit=circt -o "$out/62_loop_carried.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/62_loop_carried.mlir" \
    "$out/62_loop_carried.mlir"

[ "$(grep -c 'hw.module' "$out/62_loop_carried.mlir")" = "2" ]
# Each module has a running flag, a carried accumulator, and a done pulse.
[ "$(grep -c 'seq.compreg %18, %clk reset %rst' "$out/62_loop_carried.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg %16, %clk reset %rst' "$out/62_loop_carried.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg %13, %clk reset %rst' "$out/62_loop_carried.mlir")" = "2" ]
# `acc` accumulates under active and reloads zero during init/done.
[ "$(grep -c 'comb.mux %3, %9, %c0_i8 : i8' "$out/62_loop_carried.mlir")" = "2" ]
[ "$(grep -c 'comb.add %5, %wd : i8' "$out/62_loop_carried.mlir")" = "2" ]
# Post-loop total/cycles capture the final accumulator on the done pulse.
[ "$(grep -c 'seq.compreg.ce sym @reg_0 %5, %clk, %15' "$out/62_loop_carried.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/62_loop_carried.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/62_loop_carried.raw.sv" | grep -v '^$' \
    > "$out/62_loop_carried.sv"
diff -u "$root/hdl-spike/expected/62_loop_carried.sv" \
    "$out/62_loop_carried.sv"

[ "$(grep -c 'assign _GEN_1 = _GEN_4 ? (_GEN_6 ? _GEN_5 + wd : _GEN_5) : 8.h0;' \
    "$out/62_loop_carried.sv")" = "2" ]
[ "$(grep -c 'else if (_GEN_9)' "$out/62_loop_carried.sv")" = "4" ]
[ "$(grep -c 'assign out = reg_0;' "$out/62_loop_carried.sv")" = "2" ]

# Logic payloads are not supported as carried state yet.
if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/62_bad_logic_carried.mojo" \
    > "$out/62_bad_logic_carried.out" 2>&1; then
  echo "FAIL: loop-carried Logic state was accepted" >&2
  exit 1
fi
grep -q 'loop-carried Logic state is not supported yet' \
    "$out/62_bad_logic_carried.out"

echo "62_loop_carried: ok"
