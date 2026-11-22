#!/usr/bin/env bash
# Automatic Sim process discovery: generator emits the step adapter.
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
    echo "50_auto_process: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/50_auto_process.mojo"
python3 "$root/hdl-spike/tools/gen_sim_step.py" "$design" \
    > "$out/50_adapter.mojo"
grep -q 'def AutoDomain_step' "$out/50_adapter.mojo"
grep -q 'sim.p1()' "$out/50_adapter.mojo"
grep -q 'sim.p2()' "$out/50_adapter.mojo"
grep -q 'commit_state(sim)' "$out/50_adapter.mojo"
if grep -q 'step(self' "$design"; then
  echo "FAIL: design should not register processes manually" >&2
  exit 1
fi

cat "$design" "$out/50_adapter.mojo" \
    "$root/hdl-spike/tests/50_auto_main.mojo" > "$out/50_auto.mojo"
"$MOJO" run "${inc[@]}" "$out/50_auto.mojo" > "$out/50_auto.txt"
grep -q '^c0 1 0$' "$out/50_auto.txt"
grep -q '^c1 2 1$' "$out/50_auto.txt"
grep -q '^c2 3 2$' "$out/50_auto.txt"

echo "50_auto_process: ok"
