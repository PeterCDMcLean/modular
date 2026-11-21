#!/usr/bin/env bash
# X/Z-aware Logic[W] comparisons return a value + mask Logic[1].
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
    echo "18_logic_compare: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/18_logic_compare.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/18_logic_compare.mojo"
diff -u "$root/hdl-spike/expected/18_logic_compare.mlir" "$out/18_logic_compare.mlir"
grep -q 'out eq_out_xz : i1' "$out/18_logic_compare.mlir"
grep -q 'out ne_out_xz : i1' "$out/18_logic_compare.mlir"
grep -q 'comb.icmp ne' "$out/18_logic_compare.mlir"

"$MOJO" build --emit=sv -o "$out/18_logic_compare.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/18_logic_compare.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/18_logic_compare.raw.sv" \
    | grep -v '^$' > "$out/18_logic_compare.sv"
diff -u "$root/hdl-spike/expected/18_logic_compare.sv" "$out/18_logic_compare.sv"
grep -q 'assign eq_out = ' "$out/18_logic_compare.sv"
grep -q 'assign eq_out_xz = ' "$out/18_logic_compare.sv"
grep -q 'assign ne_out = ' "$out/18_logic_compare.sv"
grep -q 'assign ne_out_xz = ' "$out/18_logic_compare.sv"

echo "18_logic_compare: ok"
