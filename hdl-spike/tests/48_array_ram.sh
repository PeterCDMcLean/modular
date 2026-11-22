#!/usr/bin/env bash
# Array-register memory: array_get/array_inject + enable mux, lowered to SV RAM.
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
    echo "48_array_ram: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/48_array_ram.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/48_array_ram.mojo"
diff -u "$root/hdl-spike/expected/48_array_ram.mlir" "$out/48_array_ram.mlir"
grep -q 'seq.firreg %3 clock %clk : !hw.array<4xi8>' \
    "$out/48_array_ram.mlir"
grep -q 'hw.array_inject %array_ram_0\[%0\], %wd' \
    "$out/48_array_ram.mlir"
grep -q 'comb.mux %we, %2, %array_ram_0 : !hw.array<4xi8>' \
    "$out/48_array_ram.mlir"
grep -q 'hw.array_get %array_ram_0\[%4\] : !hw.array<4xi8>, i2' \
    "$out/48_array_ram.mlir"
if grep -q 'seq.hlmem' "$out/48_array_ram.mlir"; then
  echo "FAIL: array-register form should not use seq.hlmem" >&2
  exit 1
fi

MOJO_HDL_DUMP_MEMORY_IR=1 "$MOJO" build --emit=sv -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/48_array_ram.mojo" 2> "$out/48_memory_ir.txt"
grep -q 'seq.firmem 0, 1, undefined, undefined : <4 x 8, mask 1>' \
    "$out/48_memory_ir.txt"
grep -q 'seq.firmem.read_port' "$out/48_memory_ir.txt"
grep -q 'seq.firmem.write_port' "$out/48_memory_ir.txt"

"$MOJO" build --emit=sv -o "$out/48_array_ram.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/48_array_ram.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/48_array_ram.raw.sv" \
    | grep -v '^$' > "$out/48_array_ram.sv"
diff -u "$root/hdl-spike/expected/48_array_ram.sv" "$out/48_array_ram.sv"
grep -q 'module mem_4x8(' "$out/48_array_ram.sv"
grep -q 'var logic \[7:0\] Memory\[0:3\];' "$out/48_array_ram.sv"
grep -q 'Memory\[W0_addr\] <= W0_data;' "$out/48_array_ram.sv"
grep -q "assign R0_data = R0_en ? Memory\[R0_addr\] : 8'bx;" "$out/48_array_ram.sv"
grep -q 'mem_4x8 mem_ext (' "$out/48_array_ram.sv"

echo "48_array_ram: ok"
