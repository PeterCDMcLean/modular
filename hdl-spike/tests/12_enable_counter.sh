#!/usr/bin/env bash
# Register enable: conditional state updates become an input mux.
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
    echo "12_enable_counter: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/12_enable_counter.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/12_enable_counter.mojo"
diff -u "$root/hdl-spike/expected/12_enable_counter.mlir" "$out/12_enable_counter.mlir"
grep -q 'in %en : i1' "$out/12_enable_counter.mlir"
grep -q 'hw.module @EnableIfElse' "$out/12_enable_counter.mlir"
grep -q 'seq.compreg.ce' "$out/12_enable_counter.mlir"
grep -q '%clk, %en' "$out/12_enable_counter.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/12_enable_counter.mlir")" = "1" ]
grep -q 'seq.compreg' "$out/12_enable_counter.mlir"

"$MOJO" build --emit=sv -o "$out/12_enable_counter.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/12_enable_counter.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/12_enable_counter.raw.sv" \
    | grep -v '^$' > "$out/12_enable_counter.sv"
diff -u "$root/hdl-spike/expected/12_enable_counter.sv" "$out/12_enable_counter.sv"
grep -q 'else if (en)' "$out/12_enable_counter.sv"
grep -q '~en ?' "$out/12_enable_counter.sv"

echo "12_enable_counter: ok"
