#!/usr/bin/env bash
# Logic[W] state: a 4-state field becomes value and X/Z mask registers.
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
    echo "17_logic_state: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/17_logic_state.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/17_logic_state.mojo"
diff -u "$root/hdl-spike/expected/17_logic_state.mlir" "$out/17_logic_state.mlir"
grep -q 'in %d_xz : i8' "$out/17_logic_state.mlir"
grep -q 'out out_xz : i8' "$out/17_logic_state.mlir"
grep -q 'reset %rst, %c5_i8' "$out/17_logic_state.mlir"
grep -q 'comb.and' "$out/17_logic_state.mlir"

"$MOJO" build --emit=sv -o "$out/17_logic_state.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/17_logic_state.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/17_logic_state.raw.sv" \
    | grep -v '^$' > "$out/17_logic_state.sv"
diff -u "$root/hdl-spike/expected/17_logic_state.sv" "$out/17_logic_state.sv"
grep -q "_GEN_1 = 8'h5;" "$out/17_logic_state.sv"
grep -q "_GEN_2 = 8'h0;" "$out/17_logic_state.sv"
grep -q 'assign out_xz' "$out/17_logic_state.sv"

echo "17_logic_state: ok"
