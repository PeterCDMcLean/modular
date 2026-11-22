#!/usr/bin/env bash
# Clock-enabled write followed by a differently-conditioned write.
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
    echo "80_mixed_enable: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/80_mixed_enable.mojo"

"$MOJO" build --emit=circt -o "$out/80_mixed_enable.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/80_mixed_enable.mlir" \
    "$out/80_mixed_enable.mlir"

[ "$(grep -c 'hw.module' "$out/80_mixed_enable.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/80_mixed_enable.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/80_mixed_enable.raw.sv" | grep -v '^$' \
    > "$out/80_mixed_enable.sv"
diff -u "$root/hdl-spike/expected/80_mixed_enable.sv" \
    "$out/80_mixed_enable.sv"

# MixedEnable: the enabled update (en ? value+1) survives as the hold path
# of the later write (other ? value+2 : ...).
grep -q 'assign _GEN_0 = _GEN_1 + 8.h1;' "$out/80_mixed_enable.sv"
grep -q 'assign _GEN = other ? _GEN_1 + 8.h2 : en ? _GEN_0 : _GEN_1;' \
    "$out/80_mixed_enable.sv"
grep -q 'assign out = _GEN_1;' "$out/80_mixed_enable.sv"

# NestedMixedEnable: the later write is mode && other, so the enabled path
# is taken only when both are false.
grep -q 'assign _GEN = mode & other ? _GEN_1 + 8.h3 : en ? _GEN_0 : _GEN_1;' \
    "$out/80_mixed_enable.sv"

echo "80_mixed_enable: ok"
