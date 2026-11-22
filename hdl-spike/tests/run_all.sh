#!/usr/bin/env bash
# Run the whole spike test flow. Any stage failure aborts.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for test in 00_emit_mlir.sh 00b_roundtrip.sh 01_dump.sh 02_inv.sh 03_sim_types.sh 04_add8.sh 05_counter.sh 06_bits_ops.sh 07_bits_bit.sh 08_bits_counter.sh 09_preset_counter.sh 10_var_bit.sh 11_logic_ops.sh 12_enable_counter.sh 13_hierarchy.sh 14_hierarchy_state.sh 15_two_domains.sh 16_params.sh 17_logic_state.sh 18_logic_compare.sh 19_reset_styles.sh 20_multi_instance.sh 21_domain_checks.sh 22_logic_child.sh 23_dependent_params.sh 24_poweron.sh 25_mem.sh 26_resettable.sh 27_mem_init.sh 28_async_mem.sh 29_param_expr.sh 30_mem_sequence.sh 31_mem_dual_read.sh 32_mem_two_writes.sh 33_resettable_logic.sh 34_mem_depth2.sh 35_clock_source.sh 36_wire.sh 37_reg.sh 38_logic_mem.sh 39_packed.sh 40_bare_array.sh 41_ram.sh 42_delay.sh 43_packed_elem.sh 44_hold.sh 45_direct_array.sh 46_logic_delay.sh 47_sim_delay.sh 48_array_ram.sh 49_packed_logic.sh 50_auto_process.sh 51_hier_reset.sh 52_domain_children.sh 53_conditional_child.sh 54_conditional_return.sh 55_memory_init.sh 56_loop_effects.sh 57_array_value.sh 58_multi_clock.sh 59_runtime_loop.sh 60_runtime_range.sh 61_done_handshake.sh 62_loop_carried.sh 63_logic_carried.sh 64_nested_runtime.sh 65_nested_carried.sh 66_carried_aggregate.sh 67_sequenced_loops.sh 68_three_level.sh 69_sequenced_carried.sh 70_runtime_break.sh 71_shared_accum.sh 72_nested_break.sh 74_shared_logic_accum.sh 75_multi_carried.sh 76_struct_carry.sh 77_struct_method.sh 78_conditional_while.sh 79_loop_in_branch.sh 80_mixed_enable.sh 81_computed_ctor.sh 82_nested_struct.sh 83_method_control.sh; do
  echo "===== $test"
  "$here/$test"
done

echo "all hdl-spike tests passed"
