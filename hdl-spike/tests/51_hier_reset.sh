#!/usr/bin/env bash
# Hierarchical reset forwarding/inversion with mixed child styles.
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
    echo "51_hier_reset: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/51_hier_reset.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/51_hier_reset.mojo"
diff -u "$root/hdl-spike/expected/51_hier_reset.mlir" "$out/51_hier_reset.mlir"
grep -q 'hw.module @ResetParentLow(in %clk : !seq.clock, in %rst_n : i1' \
    "$out/51_hier_reset.mlir"
grep -q 'hw.instance "a" @AsyncLowChild(clk: %clk: !seq.clock, rst_n: %rst_n' \
    "$out/51_hier_reset.mlir"
grep -q 'hw.instance "b" @SyncHighChild(clk: %clk: !seq.clock, rst: %0' \
    "$out/51_hier_reset.mlir"
grep -q 'hw.module @ResetParentHigh(in %clk : !seq.clock, in %rst : i1' \
    "$out/51_hier_reset.mlir"
grep -q 'hw.instance "a" @AsyncLowChild(clk: %clk: !seq.clock, rst_n: %0' \
    "$out/51_hier_reset.mlir"
grep -q 'hw.instance "b" @SyncHighChild(clk: %clk: !seq.clock, rst: %rst' \
    "$out/51_hier_reset.mlir"
grep -q 'seq.firreg.*reset async' "$out/51_hier_reset.mlir"
grep -q 'seq.compreg.*reset %rst' "$out/51_hier_reset.mlir"

"$MOJO" build --emit=sv -o "$out/51_hier_reset.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/51_hier_reset.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/51_hier_reset.raw.sv" \
    | grep -v '^$' > "$out/51_hier_reset.sv"
diff -u "$root/hdl-spike/expected/51_hier_reset.sv" "$out/51_hier_reset.sv"
grep -q '.rst_n (rst_n)' "$out/51_hier_reset.sv"
grep -q '.rst (~rst_n)' "$out/51_hier_reset.sv"
grep -q '.rst_n (~rst)' "$out/51_hier_reset.sv"
grep -q '.rst (rst)' "$out/51_hier_reset.sv"
grep -q 'always @(posedge clk or posedge _GEN)' "$out/51_hier_reset.sv"
grep -q 'always @(posedge clk)' "$out/51_hier_reset.sv"

echo "51_hier_reset: ok"
