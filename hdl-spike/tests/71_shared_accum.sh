#!/usr/bin/env bash
# Carried state shared across both loops of a runtime sequence.
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
    echo "71_shared_accum: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/71_shared_accum.mojo"

"$MOJO" build --emit=circt -o "$out/71_shared_accum.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/71_shared_accum.mlir" \
    "$out/71_shared_accum.mlir"

[ "$(grep -c 'hw.module' "$out/71_shared_accum.mlir")" = "1" ]

"$MOJO" build --emit=sv -o "$out/71_shared_accum.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/71_shared_accum.raw.sv" | grep -v '^$' \
    > "$out/71_shared_accum.sv"
diff -u "$root/hdl-spike/expected/71_shared_accum.sv" \
    "$out/71_shared_accum.sv"

# The first loop holds its running flag and counter after completion.
grep -q "_GEN_7 <= 1'h1;" "$out/71_shared_accum.sv"
grep -q 'assign _GEN_4 = _GEN_9 ? _GEN_10 : _GEN_6;' \
    "$out/71_shared_accum.sv"
# Its accumulator is preserved ...
grep -q 'assign _GEN_5 = _GEN_7 ? (_GEN_9 ? _GEN_8 + wd : _GEN_8) : 8.h0;' \
    "$out/71_shared_accum.sv"
# ... and seeds the second loop's carried register.
grep -q 'assign _GEN_3 = _GEN_14 ? (_GEN_16 ? _GEN_15 + wd : _GEN_15) : _GEN_8;' \
    "$out/71_shared_accum.sv"
# The post-loop total samples the second loop's final accumulator on its done.
grep -q 'else if (_GEN_19)' "$out/71_shared_accum.sv"
grep -q 'reg_0 <= _GEN_15;' "$out/71_shared_accum.sv"

echo "71_shared_accum: ok"
