#!/usr/bin/env bash
# Carried state inside a sequenced runtime loop (Bits and Logic).
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
    echo "69_sequenced_carried: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/69_sequenced_carried.mojo"

"$MOJO" build --emit=circt -o "$out/69_sequenced_carried.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/69_sequenced_carried.mlir" \
    "$out/69_sequenced_carried.mlir"

[ "$(grep -c 'hw.module' "$out/69_sequenced_carried.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/69_sequenced_carried.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/69_sequenced_carried.raw.sv" | grep -v '^$' \
    > "$out/69_sequenced_carried.sv"
diff -u "$root/hdl-spike/expected/69_sequenced_carried.sv" \
    "$out/69_sequenced_carried.sv"

# Bits accumulator: running ? (started-active ? acc + wd : acc) : 0.
grep -q 'assign _GEN_3 = _GEN_15 ? (_GEN_17 ? _GEN_16 + wd : _GEN_16) : 8.h0;' \
    "$out/69_sequenced_carried.sv"
grep -q 'assign _GEN_1 = _GEN_12 | ~_GEN_19 & _GEN_14;' \
    "$out/69_sequenced_carried.sv"
grep -q 'assign _GEN_0 = _GEN_14 & (~_GEN_15 | ~_GEN_19);' \
    "$out/69_sequenced_carried.sv"
[ "$(grep -c 'else if (_GEN_20)' "$out/69_sequenced_carried.sv")" = "2" ]

# Logic accumulator: value/mask carry, started-gated running, done muxes.
grep -q 'assign _GEN_6 = _GEN_15 ? {8{_GEN_18}} & wd | _GEN_16 : wd;' \
    "$out/69_sequenced_carried.sv"
grep -q 'assign _GEN_2 = _GEN_14 & (~_GEN_15 | ~_GEN_20);' \
    "$out/69_sequenced_carried.sv"
grep -q 'assign _GEN_1 = _GEN_21 ? _GEN_16 : _GEN_22;' \
    "$out/69_sequenced_carried.sv"
grep -q 'assign _GEN_0 = _GEN_21 ? _GEN_17 : _GEN_23;' \
    "$out/69_sequenced_carried.sv"
[ "$(grep -c 'else if (_GEN_21)' "$out/69_sequenced_carried.sv")" = "1" ]

echo "69_sequenced_carried: ok"
