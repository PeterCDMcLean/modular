#!/usr/bin/env bash
# Packed constant reset decoding and unwritten-register hold behavior.
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
    echo "44_hold: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/44_hold.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/44_hold.mojo"
diff -u "$root/hdl-spike/expected/44_hold.mlir" "$out/44_hold.mlir"
[ "$(grep -c 'seq.compreg' "$out/44_hold.mlir")" = "2" ]
grep -q 'hw.module @PackedConstHold' "$out/44_hold.mlir"
grep -q 'hw.constant 67305985 : i32' "$out/44_hold.mlir"
grep -q 'seq.compreg %1, %clk reset %rst, %c67305985_i32' \
    "$out/44_hold.mlir"
grep -q 'hw.module @UnwrittenBits' "$out/44_hold.mlir"
grep -q 'seq.compreg %1, %clk reset %rst, %c7_i8' "$out/44_hold.mlir"

"$MOJO" build --emit=sv -o "$out/44_hold.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/44_hold.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/44_hold.raw.sv" \
    | grep -v '^$' > "$out/44_hold.sv"
diff -u "$root/hdl-spike/expected/44_hold.sv" "$out/44_hold.sv"
grep -q "var logic \[31:0\] _GEN = 32'h4030201;" "$out/44_hold.sv"
grep -q "var logic \[7:0\] _GEN = 8'h7;" "$out/44_hold.sv"
grep -q '_GEN <= _GEN;' "$out/44_hold.sv"

echo "44_hold: ok"
