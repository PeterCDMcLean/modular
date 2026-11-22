#!/usr/bin/env bash
# Value-returning struct methods used inside runtime loops.
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
    echo "84_value_method: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/84_value_method.mojo"

"$MOJO" build --emit=circt -o "$out/84_value_method.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/84_value_method.mlir" \
    "$out/84_value_method.mlir"

[ "$(grep -c 'hw.module' "$out/84_value_method.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/84_value_method.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/84_value_method.raw.sv" | grep -v '^$' \
    > "$out/84_value_method.sv"
diff -u "$root/hdl-spike/expected/84_value_method.sv" \
    "$out/84_value_method.sv"

# The non-conditional bump result is value + wd.
grep -q '_GEN_8 = _GEN_7 ? _GEN_6 + wd : _GEN_6;' "$out/84_value_method.sv"
# The conditional pick result merges its early return (en ? wd) with the
# fallback (self.value), then both results feed the accumulator.
grep -q '_GEN_7 & en ? wd : _GEN_6' "$out/84_value_method.sv"
grep -q '_GEN_5 + (_GEN_7 & en ? wd : _GEN_6)' "$out/84_value_method.sv"
grep -q '+ _GEN_8' "$out/84_value_method.sv"
grep -q 'else if (_GEN_11)' "$out/84_value_method.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/84_value_method.sv"

# Logic return values carry both value and mask into the accumulator, and the
# cell's merged value is returned to the loop body.
grep -q 'assign _GEN_6 = _GEN_8 ? _GEN_14 : init;' "$out/84_value_method.sv"
grep -q 'assign _GEN_5 = _GEN_8 ? _GEN_15 : init_xz;' "$out/84_value_method.sv"
grep -q 'assign _GEN_4 = _GEN_8 ? {8{_GEN_13}} & _GEN_14 | _GEN_11 : init;' \
    "$out/84_value_method.sv"
grep -q 'assign _GEN_0 = _GEN_18 ? _GEN_11 : _GEN_19;' "$out/84_value_method.sv"

echo "84_value_method: ok"
