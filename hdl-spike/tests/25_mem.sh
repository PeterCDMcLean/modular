#!/usr/bin/env bash
# Mem[W,N]: per-entry clock-enabled registers and a combinational read mux.
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
    echo "25_mem: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/25_mem.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/25_mem.mojo"
diff -u "$root/hdl-spike/expected/25_mem.mlir" "$out/25_mem.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/25_mem.mlir")" = "4" ]
grep -q 'sym @mem_0_0' "$out/25_mem.mlir"
grep -q 'sym @mem_0_3' "$out/25_mem.mlir"
grep -q 'comb.mux' "$out/25_mem.mlir"
grep -q 'comb.icmp eq %addr' "$out/25_mem.mlir"

"$MOJO" build --emit=sv -o "$out/25_mem.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/25_mem.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/25_mem.raw.sv" \
    | grep -v '^$' > "$out/25_mem.sv"
diff -u "$root/hdl-spike/expected/25_mem.sv" "$out/25_mem.sv"
grep -q 'mem_0_0' "$out/25_mem.sv"
grep -q 'else if (_GEN_2)' "$out/25_mem.sv"
grep -q 'addr == 64.h3 ? mem_0_3' "$out/25_mem.sv"

echo "25_mem: ok"
