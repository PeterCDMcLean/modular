hw.module @TwoDomains(in %clk_run_a : !seq.clock, in %rst_run_a : i1, in %clk_run_b : !seq.clock, in %rst_run_b : i1, out run_a_out : i8, out run_b_out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk_run_a reset %rst_run_a, %c0_i8_0 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  %c2_i8 = hw.constant 2 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %4 = seq.compreg %5, %clk_run_b reset %rst_run_b, %c0_i8_2 initial %3 : i8  
  %5 = comb.add %4, %c2_i8 : i8
  hw.output %1, %4 : i8, i8
}
