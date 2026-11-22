#!/usr/bin/env bash
# Direct array element assignment: mem[i] = Reg[T](value).
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
    echo "45_direct_array: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/45_direct_array.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/45_direct_array.mojo"
diff -u "$root/hdl-spike/expected/45_direct_array.mlir" "$out/45_direct_array.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/45_direct_array.mlir")" = "8" ]
grep -q 'hw.module @DirectArraySet(in %i : i64, in %v : i8' \
    "$out/45_direct_array.mlir"
grep -q 'hw.module @DirectStaticSet(in %v : i8' "$out/45_direct_array.mlir"
grep -q 'hw.module @DirectLogicSet(in %i : i64, in %v : i8, in %v_xz : i8' \
    "$out/45_direct_array.mlir"
grep -q 'sym @mem_0_0_xz %v_xz' "$out/45_direct_array.mlir"
grep -q 'seq.compreg.ce sym @mem_0_1 %mem_0_1' "$out/45_direct_array.mlir"

"$MOJO" build --emit=sv -o "$out/45_direct_array.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/45_direct_array.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/45_direct_array.raw.sv" \
    | grep -v '^$' > "$out/45_direct_array.sv"
diff -u "$root/hdl-spike/expected/45_direct_array.sv" "$out/45_direct_array.sv"
grep -q 'module DirectArraySet(' "$out/45_direct_array.sv"
grep -q 'module DirectStaticSet(' "$out/45_direct_array.sv"
grep -q 'module DirectLogicSet(' "$out/45_direct_array.sv"
grep -q 'mem_0_0 <= v;' "$out/45_direct_array.sv"
grep -q 'mem_0_0_xz <= v_xz;' "$out/45_direct_array.sv"
grep -q 'assign out = mem_0_0;' "$out/45_direct_array.sv"

echo "45_direct_array: ok"
