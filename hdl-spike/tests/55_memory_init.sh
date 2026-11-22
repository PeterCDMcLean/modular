#!/usr/bin/env bash
# Memory initialization: constructor fill and PowerOn for Ram/ArrayRam.
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
    echo "55_memory_init: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/55_memory_init.mojo"

"$MOJO" build --emit=circt -o "$out/55_memory_init.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/55_memory_init.mlir" \
    "$out/55_memory_init.mlir"

# The array-register form carries per-entry reset values and a packed
# power-on preset; the HLMem form carries both as attributes.
grep -q 'seq.firreg %4 clock %clk reset sync %rst, %2 preset 151587081' \
    "$out/55_memory_init.mlir"
grep -q 'seq.firreg %5 clock %clk reset async %3, %2 preset 67305985' \
    "$out/55_memory_init.mlir"
grep -q 'hdl.poweron = \[9 : i8, 9 : i8, 9 : i8, 9 : i8\], hdl.reset = \[1 : i8, 2 : i8, 3 : i8, 4 : i8\]' \
    "$out/55_memory_init.mlir"
grep -q 'hdl.reset_async' "$out/55_memory_init.mlir"
# An initialized array register is not turned into a firmem, which would drop
# the reset/preset state.
if grep -q 'seq.firmem' "$out/55_memory_init.mlir"; then
  echo "FAIL: initialized memory should not be inferred as seq.firmem" >&2
  exit 1
fi

"$MOJO" build --emit=sv -o "$out/55_memory_init.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/55_memory_init.raw.sv" | grep -v '^$' \
    > "$out/55_memory_init.sv"
diff -u "$root/hdl-spike/expected/55_memory_init.sv" \
    "$out/55_memory_init.sv"

# Power-on contents are blocking assignments in an initial block.
[ "$(grep -c 'initial begin' "$out/55_memory_init.sv")" = "4" ]
grep -q 'ram_1\[2.h0\] = 8.h9;' "$out/55_memory_init.sv"
grep -q 'array_ram_1\[2.h3\] = 8.h9;' "$out/55_memory_init.sv"
# Reset contents are nonblocking assignments in the reset branch.
grep -q 'ram_1\[2.h0\] <= 8.h1;' "$out/55_memory_init.sv"
grep -q 'array_ram_1\[2.h3\] <= 8.h4;' "$out/55_memory_init.sv"
grep -q 'always_ff @(posedge clk or posedge rst)' \
    "$out/55_memory_init.sv"
grep -q 'always_ff @(posedge clk or posedge _GEN)' \
    "$out/55_memory_init.sv"

# Native Sim starts from the constructor fill and applies writes.
"$MOJO" run "${inc[@]}" "$root/hdl-spike/tests/55_sim_mem_init.mojo" \
    > "$out/55_sim_mem_init.txt"
grep -q '^ram 1 2 3 4$' "$out/55_sim_mem_init.txt"
grep -q '^ram_write 9$' "$out/55_sim_mem_init.txt"
grep -q '^array 5 6 7 8$' "$out/55_sim_mem_init.txt"
grep -q '^array_write 10$' "$out/55_sim_mem_init.txt"

echo "55_memory_init: ok"
