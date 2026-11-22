#!/usr/bin/env bash
# Native Sim domain commit: process tree first, then commit_state.
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
    echo "47_sim_delay: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" run "${inc[@]}" "$root/hdl-spike/tests/12_sim_delay.mojo" \
    > "$out/12_sim_delay.txt"
grep -q '^c0 1 0$' "$out/12_sim_delay.txt"
grep -q '^c1 2 1$' "$out/12_sim_delay.txt"
grep -q '^c2 3 2$' "$out/12_sim_delay.txt"
grep -q '^a0 1 0 1 0$' "$out/12_sim_delay.txt"
grep -q '^a1 2 1 2 1$' "$out/12_sim_delay.txt"

echo "47_sim_delay: ok"
