#!/usr/bin/env bash
# Run the whole spike test flow. Any stage failure aborts.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for test in 00_emit_mlir.sh 00b_roundtrip.sh 01_dump.sh 02_inv.sh 03_sim_types.sh 04_add8.sh 05_counter.sh; do
  echo "===== $test"
  "$here/$test"
done

echo "all hdl-spike tests passed"
