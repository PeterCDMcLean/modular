#!/usr/bin/env bash
# Reset styles: sync/async x active-high/low via ResetStyle[style].
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
    echo "19_reset_styles: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/19_reset_styles.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/19_reset_styles.mojo"
diff -u "$root/hdl-spike/expected/19_reset_styles.mlir" "$out/19_reset_styles.mlir"
grep -q 'reset async %rst' "$out/19_reset_styles.mlir"
grep -q 'in %rst_n : i1' "$out/19_reset_styles.mlir"
grep -q 'seq.compreg' "$out/19_reset_styles.mlir"
grep -q 'rst_n: %0' "$out/19_reset_styles.mlir"

"$MOJO" build --emit=sv -o "$out/19_reset_styles.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/19_reset_styles.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/19_reset_styles.raw.sv" \
    | grep -v '^$' > "$out/19_reset_styles.sv"
diff -u "$root/hdl-spike/expected/19_reset_styles.sv" "$out/19_reset_styles.sv"
grep -q 'always @(posedge clk or posedge rst)' "$out/19_reset_styles.sv"
grep -q 'if (~rst_n)' "$out/19_reset_styles.sv"
grep -q '.rst_n (~rst)' "$out/19_reset_styles.sv"

echo "19_reset_styles: ok"
