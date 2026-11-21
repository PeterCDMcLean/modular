#!/usr/bin/env bash
# 4-state memory: Mem[Logic[8],4] lowers to value/mask register pairs.
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
    echo "38_logic_mem: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/38_logic_mem.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/38_logic_mem.mojo"
diff -u "$root/hdl-spike/expected/38_logic_mem.mlir" "$out/38_logic_mem.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/38_logic_mem.mlir")" = "8" ]
grep -q 'sym @mem_0_0 %wd, %clk' "$out/38_logic_mem.mlir"
grep -q 'sym @mem_0_0_xz %wd_xz, %clk' "$out/38_logic_mem.mlir"
grep -q 'sym @mem_0_3 %wd, %clk' "$out/38_logic_mem.mlir"
grep -q 'sym @mem_0_3_xz %wd_xz, %clk' "$out/38_logic_mem.mlir"
grep -q 'comb.mux.*mem_0_3_xz' "$out/38_logic_mem.mlir"
grep -q 'hw.output %23, %24' "$out/38_logic_mem.mlir"

"$MOJO" build --emit=sv -o "$out/38_logic_mem.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/38_logic_mem.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/38_logic_mem.raw.sv" \
    | grep -v '^$' > "$out/38_logic_mem.sv"
diff -u "$root/hdl-spike/expected/38_logic_mem.sv" "$out/38_logic_mem.sv"
grep -q "mem_0_0 = 8'h1;" "$out/38_logic_mem.sv"
grep -q "mem_0_0_xz = 8'h0;" "$out/38_logic_mem.sv"
grep -q "mem_0_1 = 8'h2;" "$out/38_logic_mem.sv"
grep -q "mem_0_2 = 8'h3;" "$out/38_logic_mem.sv"
grep -q "mem_0_3 = 8'h4;" "$out/38_logic_mem.sv"
grep -q 'mem_0_3_xz <= wd_xz;' "$out/38_logic_mem.sv"
grep -q 'assign out_xz =' "$out/38_logic_mem.sv"

echo "38_logic_mem: ok"
