#!/usr/bin/env bash
# Async memory: firreg entries with per-entry write muxes.
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
    echo "28_async_mem: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/28_async_mem.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/28_async_mem.mojo"
diff -u "$root/hdl-spike/expected/28_async_mem.mlir" "$out/28_async_mem.mlir"
[ "$(grep -c 'seq.firreg' "$out/28_async_mem.mlir")" = "4" ]
grep -q 'reset async %rst, %c5_i8 preset 5' "$out/28_async_mem.mlir"
grep -q 'comb.mux' "$out/28_async_mem.mlir"

"$MOJO" build --emit=sv -o "$out/28_async_mem.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/28_async_mem.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/28_async_mem.raw.sv" \
    | grep -v '^$' > "$out/28_async_mem.sv"
diff -u "$root/hdl-spike/expected/28_async_mem.sv" "$out/28_async_mem.sv"
grep -q 'always @(posedge clk or posedge rst)' "$out/28_async_mem.sv"
grep -q "mem_1_0 <= we & addr == 64'h0 ? wdata : mem_1_0;" \
    "$out/28_async_mem.sv"

echo "28_async_mem: ok"
