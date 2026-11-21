#!/usr/bin/env bash
# Bits[W] dynamic bit select lowers to comb.shru + comb.extract.
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
    echo "10_var_bit: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/10_var_bit.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/10_var_bit.mojo"
diff -u "$root/hdl-spike/expected/10_var_bit.mlir" "$out/10_var_bit.mlir"
grep -q 'in %i : i64' "$out/10_var_bit.mlir"
grep -q 'comb.shru %a, %0 : i12' "$out/10_var_bit.mlir"

"$MOJO" build --emit=sv -o "$out/10_var_bit.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/10_var_bit.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/10_var_bit.raw.sv" \
    | grep -v '^$' > "$out/10_var_bit.sv"
diff -u "$root/hdl-spike/expected/10_var_bit.sv" "$out/10_var_bit.sv"
grep -q 'a >> i\[11:0\]' "$out/10_var_bit.sv"

echo "10_var_bit: ok"
