#!/usr/bin/env bash
# Struct methods updating carried fields inside a runtime loop.
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
    echo "77_struct_method: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/77_struct_method.mojo"

"$MOJO" build --emit=circt -o "$out/77_struct_method.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/77_struct_method.mlir" \
    "$out/77_struct_method.mlir"

[ "$(grep -c 'hw.module' "$out/77_struct_method.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/77_struct_method.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/77_struct_method.raw.sv" | grep -v '^$' \
    > "$out/77_struct_method.sv"
diff -u "$root/hdl-spike/expected/77_struct_method.sv" \
    "$out/77_struct_method.sv"

# StructMethodCarry: p.bump updates both fields inside the loop. Each field
# is a carried register updated from the inlined method body.
grep -q 'assign _GEN_2 = _GEN_4 ? (_GEN_7 ? _GEN_5 + wd : _GEN_5) : wd;' \
    "$out/77_struct_method.sv"
grep -q 'assign _GEN_1 = _GEN_4 ? (_GEN_7 ? _GEN_6 + 8.h3 : _GEN_6) : 8.h2;' \
    "$out/77_struct_method.sv"
grep -q 'else if (_GEN_10)' "$out/77_struct_method.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/77_struct_method.sv"
grep -q 'reg_1 <= _GEN_6;' "$out/77_struct_method.sv"

# LogicStructMethodCarry: p.merge updates a Logic field through a method.
# The value and mask are both carried, and the tag uses the inlined +1.
grep -q 'assign _GEN_5 = _GEN_7 ? {8{_GEN_11}} & wd | _GEN_8 : init;' \
    "$out/77_struct_method.sv"
grep -q ': init_xz;' "$out/77_struct_method.sv"
grep -q 'assign _GEN_3 = _GEN_7 ? (_GEN_11 ? _GEN_10 + 4.h1 : _GEN_10) : 4.h5;' \
    "$out/77_struct_method.sv"
grep -q 'assign _GEN_0 = _GEN_14 ? _GEN_8 : _GEN_15;' \
    "$out/77_struct_method.sv"
grep -q 'assign _GEN = _GEN_14 ? _GEN_9 : _GEN_16;' \
    "$out/77_struct_method.sv"
grep -q 'reg_1 <= _GEN_10;' "$out/77_struct_method.sv"

echo "77_struct_method: ok"
