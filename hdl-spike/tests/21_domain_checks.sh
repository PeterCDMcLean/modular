#!/usr/bin/env bash
# Cross-domain checks: multiple drivers and cross-process reads are errors.
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
    echo "21_domain_checks: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

if "$MOJO" build --emit=circt -o "$out/21_bad_multi_driver.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/21_bad_multi_driver.mojo" \
    > "$out/21_bad_multi_driver.out" 2> "$out/21_bad_multi_driver.err"; then
  echo "FAIL: multiple drivers were accepted" >&2
  exit 1
fi
grep -q "field 'count' is driven from multiple processes" \
    "$out/21_bad_multi_driver.err"
grep -q "run_a" "$out/21_bad_multi_driver.err"
grep -q "run_b" "$out/21_bad_multi_driver.err"

if "$MOJO" build --emit=circt -o "$out/21_bad_cross_read.mlir" "${inc[@]}" \
    "$root/hdl-spike/designs/21_bad_cross_read.mojo" \
    > "$out/21_bad_cross_read.out" 2> "$out/21_bad_cross_read.err"; then
  echo "FAIL: cross-domain read was accepted" >&2
  exit 1
fi
grep -q "field 'count' is read from process 'run_b'" \
    "$out/21_bad_cross_read.err"
grep -q "driven from 'run_a'" "$out/21_bad_cross_read.err"

echo "21_domain_checks: ok"
