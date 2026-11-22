#!/usr/bin/env bash
# Multi-clock diagnostics: cross-domain state, child state, and memories.
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
    echo "58_multi_clock: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

run_bad() {
  local name="$1"
  local expected="$2"
  if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
      "$root/hdl-spike/designs/$name.mojo" > "$out/$name.out" 2>&1; then
    echo "FAIL: $name was accepted" >&2
    exit 1
  fi
  grep -q "$expected" "$out/$name.out"
}

# A direct child-state read/write from another domain.
run_bad 58_bad_child_state_read \
  "child instance 'child' is ticked from process 'run_a' (domain 'clk_run_a') but its field 0 is accessed from process 'peek_b' (domain 'clk_peek_b'); the access crosses clock domains"
run_bad 58_bad_child_state_write \
  "child instance 'child' is ticked from process 'run_a' (domain 'clk_run_a') but its field 0 is accessed from process 'poke_b' (domain 'clk_poke_b'); the access crosses clock domains"

# Memories are state too: reads and writes across domains are errors.
run_bad 58_bad_mem_cross_read \
  "field 'mem' is read from process 'run_b' (domain 'clk_run_b') but driven from 'run_a' (domain 'clk_run_a'); the access crosses clock domains"
run_bad 58_bad_mem_multi_write \
  "memory 'mem' is written from process 'run_b' (domain 'clk_run_b') but driven from 'run_a' (domain 'clk_run_a'); the access crosses clock domains"
run_bad 58_bad_ram_cross_read \
  "field 'ram' is read from process 'run_b' (domain 'clk_run_b') but driven from 'run_a' (domain 'clk_run_a'); the access crosses clock domains"

# Plain register reads/writes carry the same domain information.
run_bad 21_bad_cross_read \
  "field 'count' is read from process 'run_b' (domain 'clk_run_b') but driven from 'run_a' (domain 'clk_run_a'); the access crosses clock domains"
run_bad 21_bad_multi_driver \
  "field 'count' is driven from multiple processes ('run_a' in domain 'clk_run_a' and 'run_b' in domain 'clk_run_b')"

# Independent state in two domains is accepted and keeps two clocks.
design="$root/hdl-spike/designs/58_multi_clock.mojo"
"$MOJO" build --emit=circt -o "$out/58_multi_clock.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/58_multi_clock.mlir" \
    "$out/58_multi_clock.mlir"
grep -q 'in %clk_run_a : !seq.clock' "$out/58_multi_clock.mlir"
grep -q 'in %clk_run_b : !seq.clock' "$out/58_multi_clock.mlir"
[ "$(grep -c 'seq.compreg.ce' "$out/58_multi_clock.mlir")" = "8" ]

"$MOJO" build --emit=sv -o "$out/58_multi_clock.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/58_multi_clock.raw.sv" | grep -v '^$' \
    > "$out/58_multi_clock.sv"
diff -u "$root/hdl-spike/expected/58_multi_clock.sv" \
    "$out/58_multi_clock.sv"
grep -q 'always @(posedge clk_run_a)' "$out/58_multi_clock.sv"
grep -q 'always @(posedge clk_run_b)' "$out/58_multi_clock.sv"

echo "58_multi_clock: ok"
