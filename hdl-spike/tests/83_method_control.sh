#!/usr/bin/env bash
# If/else control flow inside inlined struct methods.
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
    echo "83_method_control: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/83_method_control.mojo"

"$MOJO" build --emit=circt -o "$out/83_method_control.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/83_method_control.mlir" \
    "$out/83_method_control.mlir"

[ "$(grep -c 'hw.module' "$out/83_method_control.mlir")" = "2" ]

"$MOJO" build --emit=sv -o "$out/83_method_control.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/83_method_control.raw.sv" | grep -v '^$' \
    > "$out/83_method_control.sv"
diff -u "$root/hdl-spike/expected/83_method_control.sv" \
    "$out/83_method_control.sv"

# ConditionalMethodCarry: the method's if/else is gated by the loop's
# active condition and by `en`; both branches update the carried value.
grep -q '_GEN_9 = _GEN_8 ? _GEN_5 + wd : _GEN_5;' \
    "$out/83_method_control.sv"
grep -q '_GEN_7 & ~en ? _GEN_9 - 8.h1 : _GEN_9) : wd;' \
    "$out/83_method_control.sv"
grep -q '_GEN_8 ? _GEN_6 + 8.h1 : _GEN_6) : 8.h0;' \
    "$out/83_method_control.sv"
grep -q 'else if (_GEN_12)' "$out/83_method_control.sv"
grep -q 'reg_0 <= _GEN_5;' "$out/83_method_control.sv"
grep -q 'reg_1 <= _GEN_6;' "$out/83_method_control.sv"

# LocalStepCarry: a local computed in the method before the if is used by
# both branches; the else branch subtracts it from the composed then value.
grep -q '_GEN_8 = wd + 8.h2;' "$out/83_method_control.sv"
grep -q '_GEN_10 = _GEN_9 ? _GEN_5 + _GEN_8 : _GEN_5;' \
    "$out/83_method_control.sv"
grep -q '_GEN_7 & ~en ? _GEN_10 - _GEN_8 : _GEN_10) : wd;' \
    "$out/83_method_control.sv"
grep -q '_GEN_9 ? _GEN_6 + 8.h1 : _GEN_6) : 8.h0;' \
    "$out/83_method_control.sv"
grep -q 'else if (_GEN_13)' "$out/83_method_control.sv"

echo "83_method_control: ok"
