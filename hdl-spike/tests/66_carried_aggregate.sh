#!/usr/bin/env bash
# Complex carried aggregates: Array payload locals across runtime loops.
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
    echo "66_carried_aggregate: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/66_carried_aggregate.mojo"

"$MOJO" build --emit=circt -o "$out/66_carried_aggregate.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/66_carried_aggregate.mlir" \
    "$out/66_carried_aggregate.mlir"

[ "$(grep -c 'hw.module' "$out/66_carried_aggregate.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg' "$out/66_carried_aggregate.mlir")" -ge 10 ]

"$MOJO" build --emit=sv -o "$out/66_carried_aggregate.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/66_carried_aggregate.raw.sv" | grep -v '^$' \
    > "$out/66_carried_aggregate.sv"
diff -u "$root/hdl-spike/expected/66_carried_aggregate.sv" \
    "$out/66_carried_aggregate.sv"

# Bits array: one 32-bit carried register, lane insert under active, reload 0.
grep -q "var logic \[31:0\] _GEN_5 = 32'h0;" "$out/66_carried_aggregate.sv"
grep -q "_GEN_5 & ~(32'hFF << _GEN_7) | {24'h0, wd} << _GEN_7" \
    "$out/66_carried_aggregate.sv"
grep -q 'reg_0 <= _GEN_5\[7:0\];' "$out/66_carried_aggregate.sv"

# Logic array: value/mask carried pair, lane insert on both, reload init.
grep -q "var logic \[31:0\] _GEN_8 = 32'h0;" "$out/66_carried_aggregate.sv"
grep -q "var logic \[31:0\] _GEN_9 = 32'h0;" "$out/66_carried_aggregate.sv"
grep -q '_GEN_8 & ~_GEN_12 | {24.h0, wd} << _GEN_11 : _GEN_8) : init;' \
    "$out/66_carried_aggregate.sv"
grep -q '_GEN_9 & ~_GEN_12 | {24.h0, wd_xz} << _GEN_11 : _GEN_9) : init_xz;' \
    "$out/66_carried_aggregate.sv"
grep -q 'assign _GEN_1 = _GEN_15 ? _GEN_8\[7:0\] : _GEN_16;' \
    "$out/66_carried_aggregate.sv"
grep -q 'assign _GEN_0 = _GEN_15 ? _GEN_9\[7:0\] : _GEN_17;' \
    "$out/66_carried_aggregate.sv"

echo "66_carried_aggregate: ok"
