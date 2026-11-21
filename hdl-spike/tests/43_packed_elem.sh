#!/usr/bin/env bash
# Packed element access: Packed.__getitem__/__setitem__ on the flat i32.
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
    echo "43_packed_elem: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/43_packed_elem.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/43_packed_elem.mojo"
diff -u "$root/hdl-spike/expected/43_packed_elem.mlir" "$out/43_packed_elem.mlir"
grep -q 'hw.module @PackedGet(in %p : i32, in %i : i64, out out : i8)' \
    "$out/43_packed_elem.mlir"
grep -q 'hw.module @PackedSet(in %p : i32, in %i : i64, in %v : i8, out out : i32)' \
    "$out/43_packed_elem.mlir"
grep -q 'comb.mul %0, %c8_i32' "$out/43_packed_elem.mlir"
grep -q 'comb.shru %p, %1' "$out/43_packed_elem.mlir"
grep -q 'comb.extract %2 from 0 : (i32) -> i8' "$out/43_packed_elem.mlir"
grep -q 'comb.shl %2, %1' "$out/43_packed_elem.mlir"
grep -q 'comb.and %p, %5' "$out/43_packed_elem.mlir"
grep -q 'comb.or %6, %3' "$out/43_packed_elem.mlir"

"$MOJO" build --emit=sv -o "$out/43_packed_elem.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/43_packed_elem.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/43_packed_elem.raw.sv" \
    | grep -v '^$' > "$out/43_packed_elem.sv"
diff -u "$root/hdl-spike/expected/43_packed_elem.sv" "$out/43_packed_elem.sv"
grep -q 'module PackedGet(' "$out/43_packed_elem.sv"
grep -q 'module PackedSet(' "$out/43_packed_elem.sv"
grep -q "wire \[31:0\] _GEN = p >> {i\[28:0\], 3'h0};" "$out/43_packed_elem.sv"
grep -q "assign out = p & ~(32'hFF << _GEN) | {24'h0, v} << _GEN;" \
    "$out/43_packed_elem.sv"

echo "43_packed_elem: ok"
