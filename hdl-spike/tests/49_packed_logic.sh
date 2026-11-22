#!/usr/bin/env bash
# 4-state Packed[Logic[8],4]: parallel value/mask lanes.
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
    echo "49_packed_logic: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/49_packed_logic.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/49_packed_logic.mojo"
diff -u "$root/hdl-spike/expected/49_packed_logic.mlir" \
    "$out/49_packed_logic.mlir"
[ "$(grep -c 'seq.compreg' "$out/49_packed_logic.mlir")" = "2" ]
grep -q 'hw.module @LogicPackedGet(in %p : i32, in %p_xz : i32' \
    "$out/49_packed_logic.mlir"
grep -q 'hw.module @LogicPackedPass(in %p : i32, in %p_xz : i32' \
    "$out/49_packed_logic.mlir"
grep -q 'hw.module @LogicPackedReg(in %din : i32, in %din_xz : i32' \
    "$out/49_packed_logic.mlir"
grep -q 'out out : i8, out out_xz : i8' "$out/49_packed_logic.mlir"
grep -q 'seq.compreg %din_xz, %clk' "$out/49_packed_logic.mlir"

"$MOJO" build --emit=sv -o "$out/49_packed_logic.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/49_packed_logic.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/49_packed_logic.raw.sv" \
    | grep -v '^$' > "$out/49_packed_logic.sv"
diff -u "$root/hdl-spike/expected/49_packed_logic.sv" \
    "$out/49_packed_logic.sv"
grep -q 'module LogicPackedGet(' "$out/49_packed_logic.sv"
grep -q 'module LogicPackedPass(' "$out/49_packed_logic.sv"
grep -q 'module LogicPackedReg(' "$out/49_packed_logic.sv"
grep -q 'assign out_xz = _GEN_1\[7:0\];' "$out/49_packed_logic.sv"
grep -q 'assign out_xz = p_xz & ~_GEN_0' "$out/49_packed_logic.sv"
grep -q '_GEN_0 <= din_xz;' "$out/49_packed_logic.sv"

echo "49_packed_logic: ok"
