#!/usr/bin/env bash
# Plain Mojo struct locals carried across a runtime loop, one register per field.
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
    echo "76_struct_carry: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/76_struct_carry.mojo"

"$MOJO" build --emit=circt -o "$out/76_struct_carry.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/76_struct_carry.mlir" \
    "$out/76_struct_carry.mlir"

[ "$(grep -c 'hw.module' "$out/76_struct_carry.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/76_struct_carry.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/76_struct_carry.raw.sv" | grep -v '^$' \
    > "$out/76_struct_carry.sv"
diff -u "$root/hdl-spike/expected/76_struct_carry.sv" \
    "$out/76_struct_carry.sv"

# StructCarry: each field gets its own carried register. `a` reloads the
# pre-loop wd and `b` reloads its constructor constant 2.
grep -q 'assign _GEN_2 = _GEN_4 ? (_GEN_7 ? _GEN_5 + wd : _GEN_5) : wd;' \
    "$out/76_struct_carry.sv"
grep -q 'assign _GEN_1 = _GEN_4 ? (_GEN_7 ? _GEN_6 + 8.h3 : _GEN_6) : 8.h2;' \
    "$out/76_struct_carry.sv"
# Post-loop fields sample the final field registers on the done pulse.
grep -q 'else if (_GEN_10)' "$out/76_struct_carry.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/76_struct_carry.sv"
grep -q 'reg_1 <= _GEN_6;' "$out/76_struct_carry.sv"

# LogicStructCarry: the Logic field carries a value/mask pair.
grep -q 'assign _GEN_5 = _GEN_7 ? {8{_GEN_11}} & wd | _GEN_8 : init;' \
    "$out/76_struct_carry.sv"
grep -q ': init_xz;' "$out/76_struct_carry.sv"
grep -q 'assign _GEN_3 = _GEN_7 ? (_GEN_11 ? _GEN_10 + 4.h1 : _GEN_10) : 4.h5;' \
    "$out/76_struct_carry.sv"
grep -q 'assign _GEN_0 = _GEN_14 ? _GEN_8 : _GEN_15;' \
    "$out/76_struct_carry.sv"
grep -q 'assign _GEN = _GEN_14 ? _GEN_9 : _GEN_16;' \
    "$out/76_struct_carry.sv"
grep -q 'reg_1 <= _GEN_10;' "$out/76_struct_carry.sv"

echo "76_struct_carry: ok"
