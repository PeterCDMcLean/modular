#!/usr/bin/env bash
# Memory initialization: constructor fill becomes reset and power-on.
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
    echo "27_mem_init: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/27_mem_init.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/27_mem_init.mojo"
diff -u "$root/hdl-spike/expected/27_mem_init.mlir" "$out/27_mem_init.mlir"
grep -q 'sym @mem_0_0.*reset %rst, %c5_i8' "$out/27_mem_init.mlir"
grep -q 'sym @mem_0_3.*reset %rst, %c5_i8' "$out/27_mem_init.mlir"
grep -q 'c5_i8.*= hw.constant 5' "$out/27_mem_init.mlir"

"$MOJO" build --emit=sv -o "$out/27_mem_init.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/27_mem_init.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/27_mem_init.raw.sv" \
    | grep -v '^$' > "$out/27_mem_init.sv"
diff -u "$root/hdl-spike/expected/27_mem_init.sv" "$out/27_mem_init.sv"
grep -q 'mem_0_0 = 8.h5;' "$out/27_mem_init.sv"
grep -q 'mem_0_0 <= 8.h5;' "$out/27_mem_init.sv"
grep -q 'mem_0_3 = 8.h5;' "$out/27_mem_init.sv"

echo "27_mem_init: ok"
