#!/usr/bin/env bash
# Per-register reset styles for Logic[W]: sync and async in one module.
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
    echo "33_resettable_logic: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/33_resettable_logic.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/33_resettable_logic.mojo"
diff -u "$root/hdl-spike/expected/33_resettable_logic.mlir" "$out/33_resettable_logic.mlir"
grep -q 'seq.compreg %10, %clk_sync_step reset %rst_sync_step, %c3_i8' \
    "$out/33_resettable_logic.mlir"
grep -q 'seq.firreg.*reset async %rst_async_step, %c5_i8 preset 5' \
    "$out/33_resettable_logic.mlir"
grep -q 'comb.xor' "$out/33_resettable_logic.mlir"

"$MOJO" build --emit=sv -o "$out/33_resettable_logic.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/33_resettable_logic.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/33_resettable_logic.raw.sv" \
    | grep -v '^$' > "$out/33_resettable_logic.sv"
diff -u "$root/hdl-spike/expected/33_resettable_logic.sv" "$out/33_resettable_logic.sv"
grep -q 'always @(posedge clk_sync_step)' "$out/33_resettable_logic.sv"
grep -q 'always @(posedge clk_async_step or posedge rst_async_step)' \
    "$out/33_resettable_logic.sv"
grep -q 'out_xz' "$out/33_resettable_logic.sv"

echo "33_resettable_logic: ok"
