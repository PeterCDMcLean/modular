#!/usr/bin/env bash
# Loop-carried Logic state: value and mask registers across iterations.
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
    echo "63_logic_carried: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/63_logic_carried.mojo"

"$MOJO" build --emit=circt -o "$out/63_logic_carried.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/63_logic_carried.mlir" \
    "$out/63_logic_carried.mlir"

[ "$(grep -c 'hw.module' "$out/63_logic_carried.mlir")" = "2" ]
# Two 4-state accumulators (value + mask) with a running flag and done pulse.
[ "$(grep -c 'seq.compreg' "$out/63_logic_carried.mlir")" -ge 12 ]

"$MOJO" build --emit=sv -o "$out/63_logic_carried.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/63_logic_carried.raw.sv" | grep -v '^$' \
    > "$out/63_logic_carried.sv"
diff -u "$root/hdl-spike/expected/63_logic_carried.sv" \
    "$out/63_logic_carried.sv"

# The carried value reloads the pre-loop `wd`, accumulates under active, and
# the mask follows the 4-state OR.
[ "$(grep -c 'assign _GEN_4 = _GEN_7 ? {8{_GEN_10}} & wd | _GEN_8 : wd;' \
    "$out/63_logic_carried.sv")" = "2" ]
[ "$(grep -c 'assign _GEN_2 = ~_GEN_7 | ~_GEN_12;' \
    "$out/63_logic_carried.sv")" = "2" ]
# total value+mask capture the final accumulator on the done pulse (the Logic
# field updates through a mux rather than a clock enable).
[ "$(grep -c 'assign _GEN_1 = _GEN_13 ? _GEN_8 : _GEN_14;' \
    "$out/63_logic_carried.sv")" = "2" ]
[ "$(grep -c 'assign _GEN_0 = _GEN_13 ? _GEN_9 : _GEN_15;' \
    "$out/63_logic_carried.sv")" = "2" ]
[ "$(grep -c 'else if (_GEN_13)' "$out/63_logic_carried.sv")" = "2" ]

echo "63_logic_carried: ok"
