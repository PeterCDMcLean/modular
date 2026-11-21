hw.module @MixedLogicReset(in %d : i8, in %d_xz : i8, in %e : i8, in %e_xz : i8, in %clk_sync_step : !seq.clock, in %rst_sync_step : i1, in %clk_async_step : !seq.clock, in %rst_async_step : i1, out sync_step_out : i8, out sync_step_out_xz : i8, out async_step_out : i8, out async_step_out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %0 = seq.initial() {
    %c3_i8_6 = hw.constant 3 : i8
    seq.yield %c3_i8_6 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %10, %clk_sync_step reset %rst_sync_step, %c3_i8 initial %0 : i8  
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_6 = hw.constant 0 : i8
    seq.yield %c0_i8_6 : i8
  } : () -> !seq.immutable<i8>
  %3 = seq.compreg %8, %clk_sync_step reset %rst_sync_step, %c0_i8_1 initial %2 : i8  
  %4 = comb.or %3, %d_xz : i8
  %5 = comb.or %3, %1 : i8
  %6 = comb.or %d_xz, %d : i8
  %7 = comb.and %4, %5 : i8
  %8 = comb.and %7, %6 : i8
  %9 = comb.and %1, %d : i8
  %c-1_i8 = hw.constant -1 : i8
  %10 = comb.xor %9, %c-1_i8 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %reg_2 = seq.firreg %17 clock %clk_async_step reset async %rst_async_step, %c5_i8 preset 5 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %reg_3 = seq.firreg %15 clock %clk_async_step reset async %rst_async_step, %c0_i8_4 preset 0 : i8
  %11 = comb.or %reg_3, %e_xz : i8
  %12 = comb.or %reg_3, %reg_2 : i8
  %13 = comb.or %e_xz, %e : i8
  %14 = comb.and %11, %12 : i8
  %15 = comb.and %14, %13 : i8
  %16 = comb.and %reg_2, %e : i8
  %c-1_i8_5 = hw.constant -1 : i8
  %17 = comb.xor %16, %c-1_i8_5 : i8
  hw.output %1, %3, %reg_2, %reg_3 : i8, i8, i8, i8
}
