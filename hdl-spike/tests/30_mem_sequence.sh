#!/usr/bin/env bash
# Per-entry memory initialization from a constructor sequence.
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
    echo "30_mem_sequence: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/30_mem_sequence.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/30_mem_sequence.mojo"
diff -u "$root/hdl-spike/expected/30_mem_sequence.mlir" "$out/30_mem_sequence.mlir"
grep -q 'sym @mem_0_0.*reset %rst, %c1_i8' "$out/30_mem_sequence.mlir"
grep -q 'sym @mem_0_1.*reset %rst, %c2_i8' "$out/30_mem_sequence.mlir"
grep -q 'sym @mem_0_2.*reset %rst, %c3_i8' "$out/30_mem_sequence.mlir"
grep -q 'sym @mem_0_3.*reset %rst, %c4_i8' "$out/30_mem_sequence.mlir"

"$MOJO" build --emit=sv -o "$out/30_mem_sequence.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/30_mem_sequence.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/30_mem_sequence.raw.sv" \
    | grep -v '^$' > "$out/30_mem_sequence.sv"
diff -u "$root/hdl-spike/expected/30_mem_sequence.sv" "$out/30_mem_sequence.sv"
grep -q "mem_0_0 = 8'h1;" "$out/30_mem_sequence.sv"
grep -q "mem_0_1 = 8'h2;" "$out/30_mem_sequence.sv"
grep -q "mem_0_2 = 8'h3;" "$out/30_mem_sequence.sv"
grep -q "mem_0_3 = 8'h4;" "$out/30_mem_sequence.sv"

echo "30_mem_sequence: ok"
