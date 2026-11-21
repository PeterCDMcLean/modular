hw.module @MixedReset(in %clk_sync_step : !seq.clock, in %rst_sync_step : i1, in %clk_async_step : !seq.clock, in %rst_async_step : i1, out sync_step_out : i8, out async_step_out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %0 = seq.initial() {
    %c3_i8_2 = hw.constant 3 : i8
    seq.yield %c3_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk_sync_step reset %rst_sync_step, %c3_i8 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  %c1_i8_0 = hw.constant 1 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %reg_1 = seq.firreg %3 clock %clk_async_step reset async %rst_async_step, %c5_i8 preset 5 : i8
  %3 = comb.add %reg_1, %c1_i8_0 : i8
  hw.output %1, %reg_1 : i8, i8
}
