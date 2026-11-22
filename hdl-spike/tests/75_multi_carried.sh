#!/usr/bin/env bash
# Two Logic value/mask pairs and two Bits values across a shared sequence.
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
    echo "75_multi_carried: compiler-rt not found; set MODULAR_HOME" >&2
    exit 1
  fi
  mkdir -p "$MODULAR_HOME"
  printf '[mojo-max]\ncompilerrt_path = %s\n' "$rt" > "$MODULAR_HOME/modular.cfg"
fi

design="$root/hdl-spike/designs/75_multi_carried.mojo"

"$MOJO" build --emit=circt -o "$out/75_multi_carried.mlir" "${inc[@]}" "$design"
diff -u "$root/hdl-spike/expected/75_multi_carried.mlir" \
    "$out/75_multi_carried.mlir"

[ "$(grep -c 'hw.module' "$out/75_multi_carried.mlir")" = "1" ]

"$MOJO" build --emit=sv -o "$out/75_multi_carried.raw.sv" "${inc[@]}" "$design"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
    "$out/75_multi_carried.raw.sv" | grep -v '^$' \
    > "$out/75_multi_carried.sv"
diff -u "$root/hdl-spike/expected/75_multi_carried.sv" \
    "$out/75_multi_carried.sv"

# The last loop's done re-arms the first loop's control state.
grep -q 'assign _GEN_10 = ~_GEN_43;' "$out/75_multi_carried.sv"
grep -q 'assign _GEN_9 = _GEN_43 ? 64.h0 :' "$out/75_multi_carried.sv"
# Each carried Bits value reloads its own pre-loop constant.
grep -q 'assign _GEN_8 = _GEN_43 | ~_GEN_21 ? 8.h0 :' "$out/75_multi_carried.sv"
grep -q 'assign _GEN_7 = _GEN_43 | ~_GEN_21 ? 8.h3 :' "$out/75_multi_carried.sv"
# Both carried Logic accumulators reload their own value ...
grep -q 'assign _GEN_6 = _GEN_43 | ~_GEN_21 ? wa :' "$out/75_multi_carried.sv"
grep -q 'assign _GEN_4 = _GEN_43 | ~_GEN_21 ? wb :' "$out/75_multi_carried.sv"
# ... and X/Z mask.
grep -q '? wa_xz' "$out/75_multi_carried.sv"
grep -q '? wb_xz' "$out/75_multi_carried.sv"
# Two Bits plus two Logic value/mask pairs are patched by the same done.
[ "$(grep -c '_GEN_43 | ~_GEN_21' "$out/75_multi_carried.sv")" = "6" ]
# The first loop's registers seed each second-loop carried register.
grep -q ': _GEN_22;' "$out/75_multi_carried.sv"
grep -q ': _GEN_24;' "$out/75_multi_carried.sv"
grep -q ': _GEN_26;' "$out/75_multi_carried.sv"
grep -q ': _GEN_27;' "$out/75_multi_carried.sv"
grep -q ': _GEN_23;' "$out/75_multi_carried.sv"
grep -q ': _GEN_25;' "$out/75_multi_carried.sv"
# Post-loop fields sample the second loop's final values on its done.
grep -q 'assign _GEN_2 = _GEN_43 ? _GEN_34 : _GEN_44;' \
    "$out/75_multi_carried.sv"
grep -q 'assign _GEN_1 = _GEN_43 ? _GEN_35 : _GEN_45;' \
    "$out/75_multi_carried.sv"
grep -q 'assign _GEN_0 = _GEN_43 ? _GEN_36 : _GEN_46;' \
    "$out/75_multi_carried.sv"
grep -q 'assign _GEN = _GEN_43 ? _GEN_37 : _GEN_47;' \
    "$out/75_multi_carried.sv"
grep -q 'reg_2 <= _GEN_38;' "$out/75_multi_carried.sv"
grep -q 'reg_3 <= _GEN_39;' "$out/75_multi_carried.sv"

echo "75_multi_carried: ok"
