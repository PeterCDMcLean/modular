#!/usr/bin/env bash
# Stage 2: lower Inv to hw/comb, in-process, and export SystemVerilog.
#
# Both products are produced by the compiler itself: `--emit=circt` prints the
# CIRCT module, and `--emit=sv` runs CIRCT's ExportVerilog in-process. No
# external `circt-opt` is required; when it is available it is used only as an
# independent cross-check of the SV.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOJO="${MOJO:-$root/bazel-bin/Mojo/tools/mojo/mojo}"
KGEN="${KGEN:-$root/bazel-bin/Mojo/tools/kgen/kgen}"
CIRCT_OPT="${CIRCT_OPT:-$HOME/circt/build/bin/circt-opt}"
out="$root/hdl-spike/build"

mkdir -p "$out"

# 1. The CIRCT module.
"$MOJO" build --emit=circt -o "$out/01_inv.mlir" \
    -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/01_inv.mojo"
diff -u "$root/hdl-spike/expected/01_inv.mlir" "$out/01_inv.mlir"

# 2. SystemVerilog, exported in-process by CIRCT's ExportVerilog.
"$MOJO" build --emit=sv -o "$out/01_inv.raw.sv" \
    -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/01_inv.mojo"
sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' "$out/01_inv.raw.sv" \
    | grep -v '^$' > "$out/01_inv.sv"
diff -u "$root/hdl-spike/expected/01_inv.sv" "$out/01_inv.sv"

# 3. The kgen tool exposes the same in-process path on stdout.
"$KGEN" --emit=sv -I "$root/bazel-bin/Mojo/stdlib/std" -I "$root/hdl-spike" \
    "$root/hdl-spike/designs/01_inv.mojo" 2>/dev/null \
    | grep -q 'assign y = ~a;'

# 4. Independent cross-check: external circt-opt on the emitted MLIR.
if [[ -x "$CIRCT_OPT" ]]; then
  "$CIRCT_OPT" "$out/01_inv.mlir" --lower-seq-to-sv --verify-each \
      -o "$out/01_inv.sv.mlir"
  "$CIRCT_OPT" "$out/01_inv.sv.mlir" --export-verilog -o /dev/null \
      > "$out/01_inv.circt-opt.sv" 2>/dev/null
  sed -e 's/[[:space:]]*\/\/.*$//' -e 's/[[:space:]]*$//' \
      "$out/01_inv.circt-opt.sv" | grep -v '^$' > "$out/01_inv.circt-opt.clean.sv"
  diff -u "$out/01_inv.sv" "$out/01_inv.circt-opt.clean.sv"
fi

# 5. Optional lint.
if command -v verilator >/dev/null 2>&1; then
  verilator --lint-only -Wall "$out/01_inv.raw.sv"
else
  echo "02_inv: verilator not installed; lint skipped" >&2
fi

echo "02_inv: ok"
