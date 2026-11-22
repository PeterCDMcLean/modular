#!/usr/bin/env bash
# Per-register reset styles: sync and async registers in one module.
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
    echo "26_resettable: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/26_resettable.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/26_resettable.mojo"
diff -u "$root/hdl-spike/expected/26_resettable.mlir" "$out/26_resettable.mlir"
grep -q 'seq.compreg %2, %clk_sync_step reset %rst_sync_step' \
    "$out/26_resettable.mlir"
grep -q 'seq.firreg.*reset async %rst_async_step' "$out/26_resettable.mlir"
grep -q 'preset 5' "$out/26_resettable.mlir"

"$MOJO" build --emit=sv -o "$out/26_resettable.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/26_resettable.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/26_resettable.raw.sv" \
    | grep -v '^$' > "$out/26_resettable.sv"
diff -u "$root/hdl-spike/expected/26_resettable.sv" "$out/26_resettable.sv"
grep -q 'always @(posedge clk_sync_step)' "$out/26_resettable.sv"
grep -q 'always @(posedge clk_async_step or posedge rst_async_step)' \
    "$out/26_resettable.sv"
grep -q 'output wire \[7:0\] sync_step_out' "$out/26_resettable.sv"

echo "26_resettable: ok"
