#!/usr/bin/env bash
# Runtime loop done handshake: post-loop code runs once per traversal.
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
    echo "61_done_handshake: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/61_done_handshake.mojo"

"$MOJO" build --emit=circt -o "$out/61_done_handshake.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/61_done_handshake.mlir" \
    "$out/61_done_handshake.mlir"

[ "$(grep -c 'hw.module' "$out/61_done_handshake.mlir")" = "2" ]
# A done pulse is the final-iteration condition delayed by one register.
[ "$(grep -c 'comb.icmp eq %20, %count : i64' "$out/61_done_handshake.mlir")" = "2" ]
[ "$(grep -c 'comb.and %2, %22 : i1' "$out/61_done_handshake.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg %23, %clk reset %rst' "$out/61_done_handshake.mlir")" = "2" ]
# The post-loop counter is enabled by the done pulse, not by `active`.
[ "$(grep -c 'seq.compreg.ce sym @reg_2 %27, %clk, %25' "$out/61_done_handshake.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/61_done_handshake.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/61_done_handshake.raw.sv" | grep -v '^$' \
    > "$out/61_done_handshake.sv"
diff -u "$root/hdl-spike/expected/61_done_handshake.sv" \
    "$out/61_done_handshake.sv"

[ "$(grep -c '_GEN_8 <= _GEN_6 & _GEN_7 == count;' "$out/61_done_handshake.sv")" = "2" ]
[ "$(grep -c 'else if (_GEN_8)' "$out/61_done_handshake.sv")" = "2" ]
[ "$(grep -c 'reg_2 <= _GEN;' "$out/61_done_handshake.sv")" = "2" ]
# `last` remains gated by the in-range condition.
[ "$(grep -c 'else if (_GEN_6)' "$out/61_done_handshake.sv")" = "2" ]

echo "61_done_handshake: ok"
