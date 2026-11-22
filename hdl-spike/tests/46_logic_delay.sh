#!/usr/bin/env bash
# Logic delayed next and past: value/mask delay chains.
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
    echo "46_logic_delay: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/46_logic_delay.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/46_logic_delay.mojo"
diff -u "$root/hdl-spike/expected/46_logic_delay.mlir" "$out/46_logic_delay.mlir"
[ "$(grep -c 'seq.compreg' "$out/46_logic_delay.mlir")" = "10" ]
grep -q 'hw.module @LogicNextDelay(in %din : i8, in %din_xz : i8' \
    "$out/46_logic_delay.mlir"
grep -q 'hw.module @LogicPastDelay(in %din : i8, in %din_xz : i8' \
    "$out/46_logic_delay.mlir"
grep -q 'out out : i8, out out_xz : i8' "$out/46_logic_delay.mlir"
grep -q 'seq.compreg %din_xz, %clk' "$out/46_logic_delay.mlir"
grep -q 'seq.compreg %3, %clk' "$out/46_logic_delay.mlir"

"$MOJO" build --emit=sv -o "$out/46_logic_delay.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/46_logic_delay.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/46_logic_delay.raw.sv" \
    | grep -v '^$' > "$out/46_logic_delay.sv"
diff -u "$root/hdl-spike/expected/46_logic_delay.sv" "$out/46_logic_delay.sv"
grep -q 'module LogicNextDelay(' "$out/46_logic_delay.sv"
grep -q 'module LogicPastDelay(' "$out/46_logic_delay.sv"
grep -q 'assign out_xz = _GEN_4;' "$out/46_logic_delay.sv"
grep -q '_GEN_2 <= _GEN_0;' "$out/46_logic_delay.sv"

echo "46_logic_delay: ok"
