hw.module @LogicStateOps(in %d : i8, in %d_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c5_i8_2 = hw.constant 5 : i8
    seq.yield %c5_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.initial() {
    %c0_i8_2 = hw.constant 0 : i8
    seq.yield %c0_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %2 = seq.compreg %10, %clk reset %rst, %c5_i8 initial %0 : i8  
  %3 = seq.compreg %8, %clk reset %rst, %c0_i8_1 initial %1 : i8  
  %4 = comb.or %3, %d_xz : i8
  %5 = comb.or %3, %2 : i8
  %6 = comb.or %d_xz, %d : i8
  %7 = comb.and %4, %5 : i8
  %8 = comb.and %7, %6 : i8
  %9 = comb.and %2, %d : i8
  %c-1_i8 = hw.constant -1 : i8
  %10 = comb.xor %9, %c-1_i8 : i8
  hw.output %2, %3 : i8, i8
}
