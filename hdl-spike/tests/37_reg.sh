#!/usr/bin/env bash
# Typed Reg: .next(n) is a clocked update; .get reads the current value.
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
    echo "37_reg: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/37_reg.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/37_reg.mojo"
diff -u "$root/hdl-spike/expected/37_reg.mlir" "$out/37_reg.mlir"
grep -q 'seq.compreg %2, %clk reset %rst, %c3_i8' "$out/37_reg.mlir"
grep -q 'comb.add %1, %c1_i8' "$out/37_reg.mlir"
# A conditional `.next` uses the register enable (compreg.ce).
grep -q 'seq.compreg.ce sym @reg_1 %4, %clk, %en reset %rst, %c1_i8_1' \
    "$out/37_reg.mlir"
if grep -q 'Reg::' "$out/37_reg.mlir"; then
  echo "FAIL: Reg calls should lower to register machinery" >&2
  exit 1
fi

"$MOJO" build --emit=sv -o "$out/37_reg.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/37_reg.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/37_reg.raw.sv" \
    | grep -v '^$' > "$out/37_reg.sv"
diff -u "$root/hdl-spike/expected/37_reg.sv" "$out/37_reg.sv"
grep -q "_GEN_1 = 8'h3;" "$out/37_reg.sv"
grep -q "reg_1 = 8'h1;" "$out/37_reg.sv"
grep -q 'always @(posedge clk)' "$out/37_reg.sv"
grep -q 'else if (en)' "$out/37_reg.sv"

echo "37_reg: ok"
