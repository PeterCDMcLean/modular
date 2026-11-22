#!/usr/bin/env bash
# Shared carried Logic state across a restarting runtime sequence.
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
    echo "74_shared_logic_accum: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/74_shared_logic_accum.mojo"

"$MOJO" build --emit=circt -o "$out/74_shared_logic_accum.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/74_shared_logic_accum.mlir" \
    "$out/74_shared_logic_accum.mlir"

[ "$(grep -c 'hw.module' "$out/74_shared_logic_accum.mlir")" = "1" ]

"$MOJO" build --emit=sv -o "$out/74_shared_logic_accum.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/74_shared_logic_accum.raw.sv" | grep -v '^$' \
    > "$out/74_shared_logic_accum.sv"
diff -u "$root/hdl-spike/expected/74_shared_logic_accum.sv" \
    "$out/74_shared_logic_accum.sv"

# The last loop's done re-arms the first loop: running clears, counter resets,
# and the shared Logic value/mask reload the pre-loop wd/wd_xz.
grep -q 'assign _GEN_5 = ~_GEN_26;' "$out/74_shared_logic_accum.sv"
grep -q 'assign _GEN_4 = _GEN_26 ? 64.h0 : _GEN_15 ? _GEN_16 : _GEN_11;' \
    "$out/74_shared_logic_accum.sv"
grep -q 'assign _GEN_3 = _GEN_26 | ~_GEN_12 ? wd : {8{_GEN_15}} & wd | _GEN_13;' \
    "$out/74_shared_logic_accum.sv"
# The value and X/Z mask both take the restart mux.
grep -q '? wd_xz' "$out/74_shared_logic_accum.sv"
[ "$(grep -c '_GEN_26 | ~_GEN_12' "$out/74_shared_logic_accum.sv")" = "2" ]
# The first loop's value/mask seed the second loop's carried registers.
grep -q 'assign _GEN_10 = _GEN_20 ? {8{_GEN_23}} & wd | _GEN_21 : _GEN_13;' \
    "$out/74_shared_logic_accum.sv"
grep -q ': _GEN_14;' "$out/74_shared_logic_accum.sv"
# The post-loop total value/mask sample the second loop's final accumulator.
grep -q 'assign _GEN_1 = _GEN_26 ? _GEN_21 : _GEN_27;' \
    "$out/74_shared_logic_accum.sv"
grep -q 'assign _GEN_0 = _GEN_26 ? _GEN_22 : _GEN_28;' \
    "$out/74_shared_logic_accum.sv"
[ "$(grep -c 'else if (_GEN_26)' "$out/74_shared_logic_accum.sv")" = "1" ]

echo "74_shared_logic_accum: ok"
