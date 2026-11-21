#!/usr/bin/env bash
# Logic-port child: value and X/Z mask ports are wired as a pair.
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
    echo "22_logic_child: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/22_logic_child.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/22_logic_child.mojo"
diff -u "$root/hdl-spike/expected/22_logic_child.mlir" "$out/22_logic_child.mlir"
grep -q 'hw.instance "inv" @LogicInverter(a: %d: i8, a_xz: %d_xz: i8)' \
    "$out/22_logic_child.mlir"
grep -q '%inv.out, %inv.out_xz' "$out/22_logic_child.mlir"

"$MOJO" build --emit=sv -o "$out/22_logic_child.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/22_logic_child.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/22_logic_child.raw.sv" \
    | grep -v '^$' > "$out/22_logic_child.sv"
diff -u "$root/hdl-spike/expected/22_logic_child.sv" "$out/22_logic_child.sv"
grep -q '.a_xz   (d_xz)' "$out/22_logic_child.sv"
grep -q '.out_xz (out_xz)' "$out/22_logic_child.sv"

echo "22_logic_child: ok"
