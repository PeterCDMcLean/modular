#!/usr/bin/env bash
# Multiple domains with distinct children; shared/double ticks are errors.
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
    echo "52_domain_children: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

"$MOJO" build --emit=circt -o "$out/52_domain_children.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/52_domain_children.mojo"
diff -u "$root/hdl-spike/expected/52_domain_children.mlir" \
    "$out/52_domain_children.mlir"
grep -q 'in %clk_run_a : !seq.clock' "$out/52_domain_children.mlir"
grep -q 'in %clk_run_b : !seq.clock' "$out/52_domain_children.mlir"
grep -q 'hw.instance "a" @ChildCounter(en: %en_a: i1, clk: %clk_run_a' \
    "$out/52_domain_children.mlir"
grep -q 'hw.instance "b" @ChildCounter(en: %en_b: i1, clk: %clk_run_b' \
    "$out/52_domain_children.mlir"

"$MOJO" build --emit=sv -o "$out/52_domain_children.raw.sv" "${inc[@]}" \
    "$root/hdl-spike/designs/52_domain_children.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/52_domain_children.raw.sv" | grep -v '^$' \
    > "$out/52_domain_children.sv"
diff -u "$root/hdl-spike/expected/52_domain_children.sv" \
    "$out/52_domain_children.sv"
grep -q 'ChildCounter a (' "$out/52_domain_children.sv"
grep -q 'ChildCounter b (' "$out/52_domain_children.sv"

if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/52_bad_shared_child.mojo" \
    > "$out/52_bad_shared_child.out" 2>&1; then
  echo "FAIL: shared child across domains was accepted" >&2
  exit 1
fi
grep -q "instance 'child' is ticked from multiple processes" \
    "$out/52_bad_shared_child.out"
grep -q "run_a" "$out/52_bad_shared_child.out"
grep -q "run_b" "$out/52_bad_shared_child.out"

if "$MOJO" build --emit=circt -o /dev/null "${inc[@]}" \
    "$root/hdl-spike/designs/52_bad_double_tick.mojo" \
    > "$out/52_bad_double_tick.out" 2>&1; then
  echo "FAIL: double-ticked child was accepted" >&2
  exit 1
fi
grep -q "instance 'child' is ticked more than once in process 'run'" \
    "$out/52_bad_double_tick.out"

echo "52_domain_children: ok"
