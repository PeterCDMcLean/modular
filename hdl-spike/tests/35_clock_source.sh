#!/usr/bin/env bash
# In-hierarchy clock source: a child module roots a divided sub-domain.
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
    echo "35_clock_source: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/35_clock_source.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/35_clock_source.mojo"
diff -u "$root/hdl-spike/expected/35_clock_source.mlir" "$out/35_clock_source.mlir"
grep -q 'seq.clock_div %clk by 2' "$out/35_clock_source.mlir"
grep -q 'seq.compreg %3, %0' "$out/35_clock_source.mlir"
grep -q 'hw.instance "child" @DivCounter' "$out/35_clock_source.mlir"

"$MOJO" build --emit=sv -o "$out/35_clock_source.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/35_clock_source.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/35_clock_source.raw.sv" \
    | grep -v '^$' > "$out/35_clock_source.sv"
diff -u "$root/hdl-spike/expected/35_clock_source.sv" "$out/35_clock_source.sv"
grep -q 'always @(posedge clock_out_1)' "$out/35_clock_source.sv"
grep -q 'DivCounter child (' "$out/35_clock_source.sv"

echo "35_clock_source: ok"
