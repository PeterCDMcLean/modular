#!/usr/bin/env bash
# Compiler-derived Sim process discovery: `--emit=sim-step` emits the adapter.
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

# The design has no marker comments: discovery reads the elaborated methods.
if grep -q '@process' "$design"; then
  echo "FAIL: design should not carry process markers" >&2
  exit 1
fi

"$MOJO" build --emit=sim-step -o "$out/50_adapter.mojo" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/50_auto_process.step.mojo" \
    "$out/50_adapter.mojo"
grep -q 'def AutoDomain_step(mut sim: AutoDomain):' "$out/50_adapter.mojo"
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

# Methods with arguments or results are not processes.
"$MOJO" build --emit=sim-step -o "$out/50_filtered.mojo" "${inc[@]}" \
    "$root/hdl-spike/designs/50_process_filter.mojo"
diff -u "$root/hdl-spike/expected/50_process_filter.step.mojo" \
    "$out/50_filtered.mojo"
grep -q 'sim.p1()' "$out/50_filtered.mojo"
if grep -Eq 'sim\.(tick|status)' "$out/50_filtered.mojo"; then
  echo "FAIL: port methods were treated as processes" >&2
  exit 1
fi

# A design with no process method is rejected.
if "$MOJO" build --emit=sim-step -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/50_bad_no_process.mojo" \
    > "$out/50_bad_no_process.out" 2>&1; then
  echo "FAIL: a design with no process was accepted" >&2
  exit 1
fi
grep -q 'no process method found' "$out/50_bad_no_process.out"

echo "50_auto_process: ok"
