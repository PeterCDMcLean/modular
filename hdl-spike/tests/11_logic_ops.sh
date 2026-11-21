#!/usr/bin/env bash
# Logic[W] 4-state values lower to value + X/Z mask nets.
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
    echo "11_logic_ops: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/11_logic_ops.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/11_logic_ops.mojo"
diff -u "$root/hdl-spike/expected/11_logic_ops.mlir" "$out/11_logic_ops.mlir"
grep -q 'in %a_xz : i8' "$out/11_logic_ops.mlir"
grep -q 'out out_xz : i8' "$out/11_logic_ops.mlir"
grep -q 'comb.and' "$out/11_logic_ops.mlir"
grep -q 'comb.or' "$out/11_logic_ops.mlir"
grep -q 'comb.xor' "$out/11_logic_ops.mlir"
grep -q 'comb.mux' "$out/11_logic_ops.mlir"

"$MOJO" build --emit=sv -o "$out/11_logic_ops.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/11_logic_ops.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/11_logic_ops.raw.sv" \
    | grep -v '^$' > "$out/11_logic_ops.sv"
diff -u "$root/hdl-spike/expected/11_logic_ops.sv" "$out/11_logic_ops.sv"
grep -q 'out_xz' "$out/11_logic_ops.sv"
grep -q 'assign out_xz' "$out/11_logic_ops.sv"

echo "11_logic_ops: ok"
