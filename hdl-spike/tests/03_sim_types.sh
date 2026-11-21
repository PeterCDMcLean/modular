#!/usr/bin/env bash
# Stage 3 (type layer): bitlib-backed Bits[W] and the 4-state Logic[W].
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
out="$root/hdl-spike/build"
inc=(-I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" -I "$HOME/bitlib-mojo")

mkdir -p "$out"

# The source build needs a compiler-rt config. Prefer an explicit one, then
# the bitlib checkout's configured one, then generate a local one.
export MODULAR_HOME="${MODULAR_HOME:-$root/hdl-spike/.modular}"
if [[ ! -f "$MODULAR_HOME/modular.cfg" ]]; then
  rt="$root/bazel-bin/Mojo/libKGENCompilerRTShared.so"
  if [[ ! -f "$rt" ]]; then
    rt="$(find -L "$root/bazel-bin" -name libKGENCompilerRTShared.so -print -quit 2>/dev/null || true)"
  fi
  if [[ -z "$rt" ]]; then
    echo "03_sim_types: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" run "${inc[@]}" "$root/hdl-spike/tests/10_sim_bits.mojo" > "$out/10_sim_bits.txt"
grep -q '^a+b 7$' "$out/10_sim_bits.txt"
grep -q '^mux 3$' "$out/10_sim_bits.txt"
grep -q '^wrap 0$' "$out/10_sim_bits.txt"

"$MOJO" run "${inc[@]}" "$root/hdl-spike/tests/11_sim_logic.mojo" > "$out/11_sim_logic.txt"
grep -q '^and 1 0 True$' "$out/11_sim_logic.txt"
grep -q '^dom 0 1$' "$out/11_sim_logic.txt"
grep -q '^xor -2 1$' "$out/11_sim_logic.txt"

echo "03_sim_types: ok"
