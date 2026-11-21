#!/usr/bin/env bash
# Multiple processes: each stateful method gets its own clock/reset domain.
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
    echo "15_two_domains: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/15_two_domains.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/15_two_domains.mojo"
diff -u "$root/hdl-spike/expected/15_two_domains.mlir" "$out/15_two_domains.mlir"
grep -q 'in %clk_run_a : !seq.clock' "$out/15_two_domains.mlir"
grep -q 'in %clk_run_b : !seq.clock' "$out/15_two_domains.mlir"
grep -q 'reset %rst_run_a' "$out/15_two_domains.mlir"
grep -q 'reset %rst_run_b' "$out/15_two_domains.mlir"
grep -q 'out run_a_out : i8' "$out/15_two_domains.mlir"
grep -q 'out run_b_out : i8' "$out/15_two_domains.mlir"

"$MOJO" build --emit=sv -o "$out/15_two_domains.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/15_two_domains.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/15_two_domains.raw.sv" \
    | grep -v '^$' > "$out/15_two_domains.sv"
diff -u "$root/hdl-spike/expected/15_two_domains.sv" "$out/15_two_domains.sv"
grep -q 'always @(posedge clk_run_a)' "$out/15_two_domains.sv"
grep -q 'always @(posedge clk_run_b)' "$out/15_two_domains.sv"
grep -q 'assign run_a_out' "$out/15_two_domains.sv"
grep -q 'assign run_b_out' "$out/15_two_domains.sv"

echo "15_two_domains: ok"
