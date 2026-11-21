#!/usr/bin/env bash
# Explicit RAM: Ram[Bits[8],4] lowers through seq.hlmem to an SV memory.
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
    echo "41_ram: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/41_ram.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/41_ram.mojo"
diff -u "$root/hdl-spike/expected/41_ram.mlir" "$out/41_ram.mlir"
grep -q 'seq.hlmem @ram_0 %clk, %rst : <4xi8>' "$out/41_ram.mlir"
grep -q 'seq.write %ram_0\[%0\] %wd wren %we' "$out/41_ram.mlir"
grep -q 'seq.read %ram_0\[%1\] rden %true' "$out/41_ram.mlir"
grep -q 'comb.extract %addr from 0 : (i64) -> i2' "$out/41_ram.mlir"
if grep -q 'seq.compreg' "$out/41_ram.mlir"; then
  echo "FAIL: RAM should be a memory, not per-entry registers" >&2
  exit 1
fi

"$MOJO" build --emit=sv -o "$out/41_ram.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/41_ram.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/41_ram.raw.sv" \
    | grep -v '^$' > "$out/41_ram.sv"
diff -u "$root/hdl-spike/expected/41_ram.sv" "$out/41_ram.sv"
grep -q 'var logic \[7:0\] ram_0\[0:3\];' "$out/41_ram.sv"
grep -q 'ram_0\[addr\[1:0\]\] <= wd;' "$out/41_ram.sv"
grep -q 'assign out = ram_0\[addr\[1:0\]\];' "$out/41_ram.sv"
grep -q 'always_ff @(posedge clk)' "$out/41_ram.sv"

echo "41_ram: ok"
