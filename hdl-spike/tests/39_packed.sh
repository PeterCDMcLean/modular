#!/usr/bin/env bash
# Packed arrays: Packed[Bits[8],4] flattens to a 32-bit port/register.
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
    echo "39_packed: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/39_packed.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/39_packed.mojo"
diff -u "$root/hdl-spike/expected/39_packed.mlir" "$out/39_packed.mlir"
grep -q 'hw.module @PackedPass(in %din : i32, out out : i32)' \
    "$out/39_packed.mlir"
grep -q 'hw.module @PackedHold(in %din : i32, in %clk : !seq.clock' \
    "$out/39_packed.mlir"
grep -q 'seq.compreg %din, %clk reset %rst, %c0_i32_0' \
    "$out/39_packed.mlir"
grep -q 'hw.module @PackedConstOut(out out : i32)' "$out/39_packed.mlir"
grep -q 'hw.constant 67305985 : i32' "$out/39_packed.mlir"
if grep -q '\[7:0\]' "$out/39_packed.mlir"; then
  echo "FAIL: packed array should be a 32-bit value" >&2
  exit 1
fi

"$MOJO" build --emit=sv -o "$out/39_packed.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/39_packed.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/39_packed.raw.sv" \
    | grep -v '^$' > "$out/39_packed.sv"
diff -u "$root/hdl-spike/expected/39_packed.sv" "$out/39_packed.sv"
grep -q 'input  wire \[31:0\] din' "$out/39_packed.sv"
grep -q 'var logic \[31:0\] _GEN' "$out/39_packed.sv"
grep -q '_GEN <= din;' "$out/39_packed.sv"
grep -q 'assign out = din;' "$out/39_packed.sv"
grep -q "assign out = 32'h4030201;" "$out/39_packed.sv"

echo "39_packed: ok"
