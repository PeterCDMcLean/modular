#!/usr/bin/env bash
# Hierarchy: a @module field becomes an hw.instance with wired ports.
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
    echo "13_hierarchy: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/13_hierarchy.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/13_hierarchy.mojo"
diff -u "$root/hdl-spike/expected/13_hierarchy.mlir" "$out/13_hierarchy.mlir"
grep -q 'hw.module @Top' "$out/13_hierarchy.mlir"
grep -q 'hw.instance "inv" @Inverter' "$out/13_hierarchy.mlir"

"$MOJO" build --emit=sv -o "$out/13_hierarchy.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/13_hierarchy.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/13_hierarchy.raw.sv" \
    | grep -v '^$' > "$out/13_hierarchy.sv"
diff -u "$root/hdl-spike/expected/13_hierarchy.sv" "$out/13_hierarchy.sv"
grep -q 'Inverter inv (' "$out/13_hierarchy.sv"
grep -q '.out (out)' "$out/13_hierarchy.sv"

echo "13_hierarchy: ok"
