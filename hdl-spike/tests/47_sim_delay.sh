#!/usr/bin/env bash
# Native Sim cycle history for delayed next and past.
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
grep -q '^t0 0 0$' "$out/12_sim_delay.txt"
grep -q '^t1 1 0 0$' "$out/12_sim_delay.txt"
grep -q '^t2 1 1 0$' "$out/12_sim_delay.txt"
grep -q '^t3 3 1 1 0$' "$out/12_sim_delay.txt"
grep -q '^e0 0$' "$out/12_sim_delay.txt"
grep -q '^e1 0$' "$out/12_sim_delay.txt"
grep -q '^e2 9 0 0$' "$out/12_sim_delay.txt"

echo "47_sim_delay: ok"
