#!/usr/bin/env bash
# Delayed updates: `.next(2) <= din` and `.past(2)`.
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
    echo "42_delay: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/42_delay.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/42_delay.mojo"
diff -u "$root/hdl-spike/expected/42_delay.mlir" "$out/42_delay.mlir"
[ "$(grep -c 'seq.compreg' "$out/42_delay.mlir")" = "5" ]
grep -q 'hw.module @NextDelay' "$out/42_delay.mlir"
grep -q 'hw.module @PastDelay' "$out/42_delay.mlir"

"$MOJO" build --emit=sv -o "$out/42_delay.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/42_delay.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/42_delay.raw.sv" \
    | grep -v '^$' > "$out/42_delay.sv"
diff -u "$root/hdl-spike/expected/42_delay.sv" "$out/42_delay.sv"
grep -q 'module NextDelay(' "$out/42_delay.sv"
grep -q 'module PastDelay(' "$out/42_delay.sv"
grep -q '_GEN_0 <= _GEN;' "$out/42_delay.sv"
grep -q '_GEN_1 <= _GEN_0;' "$out/42_delay.sv"
grep -q 'assign out = _GEN_1;' "$out/42_delay.sv"

echo "42_delay: ok"
