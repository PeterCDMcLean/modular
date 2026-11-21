#!/usr/bin/env bash
# Arbitrary-depth memory initialization from a variadic constructor sequence.
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
    echo "34_mem_depth2: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/34_mem_depth2.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/34_mem_depth2.mojo"
diff -u "$root/hdl-spike/expected/34_mem_depth2.mlir" "$out/34_mem_depth2.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/34_mem_depth2.mlir")" = "2" ]
grep -q 'sym @mem_0_0.*reset %rst, %c7_i8' "$out/34_mem_depth2.mlir"
grep -q 'sym @mem_0_1.*reset %rst, %c9_i8' "$out/34_mem_depth2.mlir"

"$MOJO" build --emit=sv -o "$out/34_mem_depth2.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/34_mem_depth2.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/34_mem_depth2.raw.sv" \
    | grep -v '^$' > "$out/34_mem_depth2.sv"
diff -u "$root/hdl-spike/expected/34_mem_depth2.sv" "$out/34_mem_depth2.sv"
grep -q "mem_0_0 = 8'h7;" "$out/34_mem_depth2.sv"
grep -q "mem_0_1 = 8'h9;" "$out/34_mem_depth2.sv"

echo "34_mem_depth2: ok"
