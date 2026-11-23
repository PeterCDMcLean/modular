#!/usr/bin/env bash
# Parameter-time functions taking unpacked and packed structs.
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
    echo "88_param_struct_function: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/88_param_struct_function.mojo"

"$MOJO" build --emit=circt -o "$out/88_param_struct_function.mlir" \
    "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/88_param_struct_function.mlir" \
    "$out/88_param_struct_function.mlir"

grep -q "hdl_clamp_to(W, hdl_Limits'{f0: 16, f1: 64})" \
    "$out/88_param_struct_function.mlir"
grep -q "hdl_clamp_packed(W, hdl_PackedLimits'{f0: 4, f1: 32})" \
    "$out/88_param_struct_function.mlir"

"$MOJO" build --emit=sv -o "$out/88_param_struct_function.raw.sv" \
    "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/88_param_struct_function.raw.sv" | grep -v '^$' \
    > "$out/88_param_struct_function.sv"
diff -u "$root/hdl-spike/expected/88_param_struct_function.sv" \
    "$out/88_param_struct_function.sv"

sv="$out/88_param_struct_function.sv"
grep -q '^typedef struct packed {$' "$sv"
grep -q '^} hdl_PackedLimits;$' "$sv"
grep -q '^typedef struct {$' "$sv"
grep -q '^} hdl_Limits;$' "$sv"
grep -q 'function automatic integer hdl_clamp_to(input integer a0, input hdl_Limits a1);' "$sv"
grep -q 'function automatic integer hdl_clamp_packed(input integer a0, input hdl_PackedLimits a1);' "$sv"
grep -q 'if ((a0 < a1.f0)) begin' "$sv"
grep -q 'return a1.f0;' "$sv"
grep -q 'if ((a0 > a1.f1)) begin' "$sv"
grep -q 'return a1.f1;' "$sv"

echo "88_param_struct_function: ok"
