#!/usr/bin/env bash
# Nested struct fields carried across runtime loops.
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
    echo "82_nested_struct: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/82_nested_struct.mojo"

"$MOJO" build --emit=circt -o "$out/82_nested_struct.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/82_nested_struct.mlir" \
    "$out/82_nested_struct.mlir"

[ "$(grep -c 'hw.module' "$out/82_nested_struct.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/82_nested_struct.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/82_nested_struct.raw.sv" | grep -v '^$' \
    > "$out/82_nested_struct.sv"
diff -u "$root/hdl-spike/expected/82_nested_struct.sv" \
    "$out/82_nested_struct.sv"

# NestedCarry: inner.value, inner.mask, and tag each get their own carried
# register. The computed constructor gives wd+1, 4, and 5 as reload values.
grep -q '_GEN_6 + wd : _GEN_6) : wd + 8.h1;' "$out/82_nested_struct.sv"
grep -q '_GEN_7 + 8.h1 : _GEN_7) : 8.h4;' "$out/82_nested_struct.sv"
grep -q '_GEN_8 + 8.h1 : _GEN_8) : 8.h5;' "$out/82_nested_struct.sv"
grep -q 'else if (_GEN_12)' "$out/82_nested_struct.sv"
grep -q 'reg_0 <= _GEN_6;' "$out/82_nested_struct.sv"
grep -q 'reg_1 <= _GEN_7;' "$out/82_nested_struct.sv"
grep -q 'reg_2 <= _GEN_8;' "$out/82_nested_struct.sv"

# NestedMethodCarry: a method on the outer struct updates nested Logic and
# Bits leaves; both are carried and post-loop reads capture them.
grep -q '_GEN_8 : init;' "$out/82_nested_struct.sv"
grep -q ': init_xz;' "$out/82_nested_struct.sv"
grep -q '_GEN_10 + 4.h1 : _GEN_10) : 4.h2;' "$out/82_nested_struct.sv"
grep -q 'assign _GEN_0 = _GEN_14 ? _GEN_8 : _GEN_15;' \
    "$out/82_nested_struct.sv"
grep -q 'reg_1 <= _GEN_10;' "$out/82_nested_struct.sv"

echo "82_nested_struct: ok"
