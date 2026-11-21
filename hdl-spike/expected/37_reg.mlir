hw.module @RegDemo(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %0 = seq.initial() {
    %c3_i8_2 = hw.constant 3 : i8
    seq.yield %c3_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c3_i8 initial %0 : i8  
  %c1_i8 = hw.constant 1 : i8
  %2 = comb.add %1, %c1_i8 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c1_i8_1 = hw.constant 1 : i8
  %3 = seq.initial() {
    %c1_i8_2 = hw.constant 1 : i8
    seq.yield %c1_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %4, %clk, %en reset %rst, %c1_i8_1 initial %3 : i8  
  %c2_i8 = hw.constant 2 : i8
  %4 = comb.add %reg_1, %c2_i8 : i8
  %5 = comb.xor %1, %reg_1 : i8
  hw.output %5 : i8
}
