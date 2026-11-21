#!/usr/bin/env bash
# Two write ports with priority: the later write wins on conflicts.
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
    echo "32_mem_two_writes: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/32_mem_two_writes.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/32_mem_two_writes.mojo"
diff -u "$root/hdl-spike/expected/32_mem_two_writes.mlir" "$out/32_mem_two_writes.mlir"
grep -q 'comb.mux %13, %wd2, %wd' "$out/32_mem_two_writes.mlir"
grep -q 'comb.or %5, %13' "$out/32_mem_two_writes.mlir"

"$MOJO" build --emit=sv -o "$out/32_mem_two_writes.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/32_mem_two_writes.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/32_mem_two_writes.raw.sv" \
    | grep -v '^$' > "$out/32_mem_two_writes.sv"
diff -u "$root/hdl-spike/expected/32_mem_two_writes.sv" "$out/32_mem_two_writes.sv"
grep -q 'assign _GEN_6 = _GEN_7 ? wd2 : wd;' "$out/32_mem_two_writes.sv"
grep -q "assign _GEN_5 = we & wa == 64'h0 | _GEN_7;" \
    "$out/32_mem_two_writes.sv"

echo "32_mem_two_writes: ok"
