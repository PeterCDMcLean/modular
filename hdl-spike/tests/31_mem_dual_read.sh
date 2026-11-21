#!/usr/bin/env bash
# Two read ports: independent read muxes over the same memory entries.
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
    echo "31_mem_dual_read: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/31_mem_dual_read.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/31_mem_dual_read.mojo"
diff -u "$root/hdl-spike/expected/31_mem_dual_read.mlir" "$out/31_mem_dual_read.mlir"
[ "$(grep -c 'comb.mux' "$out/31_mem_dual_read.mlir")" = "6" ]
grep -q 'comb.icmp eq %addr_a' "$out/31_mem_dual_read.mlir"
grep -q 'comb.icmp eq %addr_b' "$out/31_mem_dual_read.mlir"

"$MOJO" build --emit=sv -o "$out/31_mem_dual_read.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/31_mem_dual_read.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/31_mem_dual_read.raw.sv" \
    | grep -v '^$' > "$out/31_mem_dual_read.sv"
diff -u "$root/hdl-spike/expected/31_mem_dual_read.sv" "$out/31_mem_dual_read.sv"
grep -q 'addr_a ==' "$out/31_mem_dual_read.sv"
grep -q 'addr_b ==' "$out/31_mem_dual_read.sv"
grep -q '\^ (addr_b ==' "$out/31_mem_dual_read.sv"

echo "31_mem_dual_read: ok"
