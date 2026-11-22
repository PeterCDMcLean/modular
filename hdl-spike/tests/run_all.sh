#!/usr/bin/env bash
# Run the whole spike test flow. Any stage failure aborts.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for test in 00_emit_mlir.sh 00b_roundtrip.sh 01_dump.sh 02_inv.sh 03_sim_types.sh 04_add8.sh 05_counter.sh 06_bits_ops.sh 07_bits_bit.sh 08_bits_counter.sh 09_preset_counter.sh 10_var_bit.sh 11_logic_ops.sh 12_enable_counter.sh 13_hierarchy.sh 14_hierarchy_state.sh 15_two_domains.sh 16_params.sh 17_logic_state.sh 18_logic_compare.sh 19_reset_styles.sh 20_multi_instance.sh 21_domain_checks.sh 22_logic_child.sh 23_dependent_params.sh 24_poweron.sh 25_mem.sh 26_resettable.sh 27_mem_init.sh 28_async_mem.sh 29_param_expr.sh 30_mem_sequence.sh 31_mem_dual_read.sh 32_mem_two_writes.sh 33_resettable_logic.sh 34_mem_depth2.sh 35_clock_source.sh 36_wire.sh 37_reg.sh 38_logic_mem.sh 39_packed.sh 40_bare_array.sh 41_ram.sh 42_delay.sh 43_packed_elem.sh 44_hold.sh 45_direct_array.sh 46_logic_delay.sh; do
  echo "===== $test"
  "$here/$test"
done

echo "all hdl-spike tests passed"
