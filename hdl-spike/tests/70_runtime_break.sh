#!/usr/bin/env bash
# Dynamic break / conditional early exit in a runtime loop.
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
    echo "70_runtime_break: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/70_runtime_break.mojo"

"$MOJO" build --emit=circt -o "$out/70_runtime_break.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/70_runtime_break.mlir" \
    "$out/70_runtime_break.mlir"

[ "$(grep -c 'hw.module' "$out/70_runtime_break.mlir")" = "2" ]
# The break is `active & stop`, and it forces the done pulse.
[ "$(grep -c 'comb.and %7, %stop : i1' "$out/70_runtime_break.mlir")" = "4" ]
[ "$(grep -c 'comb.or %16, %14 : i1' "$out/70_runtime_break.mlir")" = "2" ]
# On a break the counter holds at the bound so the next cycle is idle.
[ "$(grep -c 'comb.mux %14, %count, %13 : i64' "$out/70_runtime_break.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg %17, %clk reset %rst' "$out/70_runtime_break.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg.ce sym @reg_0 %5, %clk, %21' \
    "$out/70_runtime_break.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/70_runtime_break.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/70_runtime_break.raw.sv" | grep -v '^$' \
    > "$out/70_runtime_break.sv"
diff -u "$root/hdl-spike/expected/70_runtime_break.sv" \
    "$out/70_runtime_break.sv"

[ "$(grep -c 'wire             _GEN_8 = _GEN_6 & stop;' \
    "$out/70_runtime_break.sv")" = "2" ]
[ "$(grep -c 'wire             _GEN_9 = _GEN_6 & _GEN_7 == count | _GEN_8;' \
    "$out/70_runtime_break.sv")" = "2" ]
[ "$(grep -c 'assign _GEN_1 = _GEN_6 ? (_GEN_8 ? count : _GEN_7) : 64.h0;' \
    "$out/70_runtime_break.sv")" = "2" ]
[ "$(grep -c 'else if (_GEN_10)' "$out/70_runtime_break.sv")" = "4" ]

echo "70_runtime_break: ok"
