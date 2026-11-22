#!/usr/bin/env bash
# Runtime loops inside if branches: branch-local done gating and value merges.
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
    echo "79_loop_in_branch: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/79_loop_in_branch.mojo"

"$MOJO" build --emit=circt -o "$out/79_loop_in_branch.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/79_loop_in_branch.mlir" \
    "$out/79_loop_in_branch.mlir"

[ "$(grep -c 'hw.module' "$out/79_loop_in_branch.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/79_loop_in_branch.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/79_loop_in_branch.raw.sv" | grep -v '^$' \
    > "$out/79_loop_in_branch.sv"
diff -u "$root/hdl-spike/expected/79_loop_in_branch.sv" \
    "$out/79_loop_in_branch.sv"

# LoopInBranch: the loop only counts while go is true, and its break is
# gated by both go and the loop's active condition.
grep -q 'go & _GEN_5 ? _GEN_4 + wd : _GEN_4' "$out/79_loop_in_branch.sv"
grep -q 'assign _GEN = go & (~_GEN_3 | ~_GEN_9);' \
    "$out/79_loop_in_branch.sv"
# loop_total is written only inside the branch after the loop, so the done
# pulse gates it.
grep -q 'else if (_GEN_10)' "$out/79_loop_in_branch.sv"
grep -q 'reg_0 <= _GEN_4;' "$out/79_loop_in_branch.sv"
# total is written after the if and merges the branch-local accumulator.
grep -q '_GEN_11 <= go ? _GEN_4 : ~go ? wd : 8.h0;' \
    "$out/79_loop_in_branch.sv"
grep -q 'assign out = _GEN_11;' "$out/79_loop_in_branch.sv"

# LogicLoopInBranch: the same merge applies to the value and mask, and the
# done-gated loop_total keeps its value/mask pair.
grep -q 'assign _GEN_0 = _GEN_15 ? _GEN_7 : _GEN_16;' \
    "$out/79_loop_in_branch.sv"
grep -q 'assign _GEN = _GEN_15 ? _GEN_8 : _GEN_17;' \
    "$out/79_loop_in_branch.sv"
grep -q '_GEN_18 <= go ? _GEN_7 : wd;' "$out/79_loop_in_branch.sv"
grep -q 'assign out = _GEN_18;' "$out/79_loop_in_branch.sv"

echo "79_loop_in_branch: ok"
