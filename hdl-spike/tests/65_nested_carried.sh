#!/usr/bin/env bash
# Loop-carried Bits and Logic state across nested runtime loops.
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
    echo "65_nested_carried: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/65_nested_carried.mojo"

"$MOJO" build --emit=circt -o "$out/65_nested_carried.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/65_nested_carried.mlir" \
    "$out/65_nested_carried.mlir"

[ "$(grep -c 'hw.module' "$out/65_nested_carried.mlir")" = "2" ]
[ "$(grep -c 'seq.compreg' "$out/65_nested_carried.mlir")" -ge 12 ]

"$MOJO" build --emit=sv -o "$out/65_nested_carried.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/65_nested_carried.raw.sv" | grep -v '^$' \
    > "$out/65_nested_carried.sv"
diff -u "$root/hdl-spike/expected/65_nested_carried.sv" \
    "$out/65_nested_carried.sv"

# Bits accumulator: running ? (both-active ? acc + wd : acc) : 0.
grep -q 'assign _GEN_0 = _GEN_5 ? (_GEN_8 ? _GEN_6 + wd : _GEN_6) : 8.h0;' \
    "$out/65_nested_carried.sv"
grep -q 'assign _GEN_1 = ~_GEN_5 | ~_GEN_12;' "$out/65_nested_carried.sv"
[ "$(grep -c 'else if (_GEN_13)' "$out/65_nested_carried.sv")" = "2" ]

# Logic accumulator: value/mask pair, reloading the pre-loop wd on done.
grep -q 'assign _GEN_3 = _GEN_8 ? {8{_GEN_12}} & wd | _GEN_9 : wd;' \
    "$out/65_nested_carried.sv"
grep -q 'assign _GEN_4 = ~_GEN_8 | ~_GEN_16;' "$out/65_nested_carried.sv"
grep -q 'assign _GEN_1 = _GEN_17 ? _GEN_9 : _GEN_18;' \
    "$out/65_nested_carried.sv"
grep -q 'assign _GEN_0 = _GEN_17 ? _GEN_10 : _GEN_19;' \
    "$out/65_nested_carried.sv"
[ "$(grep -c 'else if (_GEN_17)' "$out/65_nested_carried.sv")" = "1" ]

# A local declared inside the outer loop is reset per outer iteration and is
# not supported as nested carried state yet.
if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/65_bad_nested_inner_local.mojo" \
    > "$out/65_bad_nested_inner_local.out" 2>&1; then
  echo "FAIL: a nested inner-only carried local was accepted" >&2
  exit 1
fi
grep -q "loop-carried local declared inside the outer loop is not supported yet" \
    "$out/65_bad_nested_inner_local.out"

echo "65_nested_carried: ok"
