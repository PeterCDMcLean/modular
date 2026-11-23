#!/usr/bin/env bash
# Parameter expressions beyond add/mul: subtraction, division, max/cond.
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
    echo "29_param_expr: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/29_param_expr.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/29_param_expr.mojo"
diff -u "$root/hdl-spike/expected/29_param_expr.mlir" "$out/29_param_expr.mlir"
# One generic module per expression form; state widths stay symbolic.
grep -q 'hw.module @SubMod<W: i32 = 8>' "$out/29_param_expr.mlir"
grep -q 'hw.module @DivMod<W: i32 = 8>' "$out/29_param_expr.mlir"
grep -q 'hw.module @MaxMod<W: i32 = 8, E: i32 = 2>' "$out/29_param_expr.mlir"
! grep -q 'SubMod_8\|DivMod_9\|MaxMod_8_2' "$out/29_param_expr.mlir"
grep -q '#hw.param.expr.add<#hw.param.decl.ref<"W">, -1>' \
    "$out/29_param_expr.mlir"
grep -q '#hw.param.verbatim<"(W / 2)">' "$out/29_param_expr.mlir"
grep -q '#hw.param.verbatim<"((E < W) ? W : E)">' "$out/29_param_expr.mlir"

"$MOJO" build --emit=sv -o "$out/29_param_expr.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/29_param_expr.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/29_param_expr.raw.sv" \
    | grep -v '^$' > "$out/29_param_expr.sv"
diff -u "$root/hdl-spike/expected/29_param_expr.sv" "$out/29_param_expr.sv"
grep -q 'wire \[W - 2:0\] _GEN;' "$out/29_param_expr.sv"
grep -q "assign out = W'(0);" "$out/29_param_expr.sv"
grep -q 'wire \[(W / 2) - 1:0\] _GEN;' "$out/29_param_expr.sv"
grep -q "_GEN_0 <= (W - 1)'(1);" "$out/29_param_expr.sv"
grep -q 'wire \[((E < W) ? W : E) - 1:0\] _GEN;' "$out/29_param_expr.sv"
grep -q "_GEN_0 <= ((E < W) ? W : E)'(3);" "$out/29_param_expr.sv"

echo "29_param_expr: ok"
