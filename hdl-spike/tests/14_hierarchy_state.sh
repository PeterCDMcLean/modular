#!/usr/bin/env bash
# Hierarchy with state: the parent forwards clock/reset to the child.
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
    echo "14_hierarchy_state: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/14_hierarchy_state.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/14_hierarchy_state.mojo"
diff -u "$root/hdl-spike/expected/14_hierarchy_state.mlir" "$out/14_hierarchy_state.mlir"
grep -q 'hw.instance "child" @ChildCounter' "$out/14_hierarchy_state.mlir"
grep -q 'clk: %clk' "$out/14_hierarchy_state.mlir"
grep -q 'rst: %rst' "$out/14_hierarchy_state.mlir"

"$MOJO" build --emit=sv -o "$out/14_hierarchy_state.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/14_hierarchy_state.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/14_hierarchy_state.raw.sv" \
    | grep -v '^$' > "$out/14_hierarchy_state.sv"
diff -u "$root/hdl-spike/expected/14_hierarchy_state.sv" "$out/14_hierarchy_state.sv"
grep -q 'ChildCounter child (' "$out/14_hierarchy_state.sv"
grep -q '.clk (clk)' "$out/14_hierarchy_state.sv"
grep -q '.rst (rst)' "$out/14_hierarchy_state.sv"

echo "14_hierarchy_state: ok"
