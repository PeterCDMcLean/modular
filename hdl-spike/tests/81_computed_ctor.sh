#!/usr/bin/env bash
# Struct-local constructors that compute field values.
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
    echo "81_computed_ctor: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/81_computed_ctor.mojo"

"$MOJO" build --emit=circt -o "$out/81_computed_ctor.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/81_computed_ctor.mlir" \
    "$out/81_computed_ctor.mlir"

[ "$(grep -c 'hw.module' "$out/81_computed_ctor.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/81_computed_ctor.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/81_computed_ctor.raw.sv" | grep -v '^$' \
    > "$out/81_computed_ctor.sv"
diff -u "$root/hdl-spike/expected/81_computed_ctor.sv" \
    "$out/81_computed_ctor.sv"

# ComputedCtorCarry: `a` reloads wd + 3 and `b` reloads 3 + 5 = 8, then both
# accumulate in the loop.
grep -q '_GEN_5 + wd : _GEN_5) : wd + 8.h3;' "$out/81_computed_ctor.sv"
grep -q '_GEN_6 + 8.h1 : _GEN_6) : 8.h8;' "$out/81_computed_ctor.sv"
grep -q 'else if (_GEN_10)' "$out/81_computed_ctor.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/81_computed_ctor.sv"
grep -q 'reg_1 <= _GEN_6;' "$out/81_computed_ctor.sv"

# LogicComputedCtor: the Logic field reloads the computed `x | x` value/mask
# pair, and the tag reloads 2 + 3 = 5.
grep -q 'assign _GEN_5 = _GEN_7 ? _GEN_8 : init;' "$out/81_computed_ctor.sv"
grep -q 'init_xz & (init_xz | ~init)' "$out/81_computed_ctor.sv"
grep -q '_GEN_10 + 4.h1 : _GEN_10) : 4.h5;' "$out/81_computed_ctor.sv"
grep -q 'assign _GEN_0 = _GEN_14 ? _GEN_8 : _GEN_15;' "$out/81_computed_ctor.sv"
grep -q 'reg_1 <= _GEN_10;' "$out/81_computed_ctor.sv"

echo "81_computed_ctor: ok"
