hw.module @EnableCounter(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i12) {
  %c1_i12 = hw.constant 1 : i12
  %c0_i12 = hw.constant 0 : i12
  %c0_i12_0 = hw.constant 0 : i12
  %0 = seq.initial() {
    %c0_i12_1 = hw.constant 0 : i12
    seq.yield %c0_i12_1 : i12
  } : () -> !seq.immutable<i12>
  %reg_0 = seq.compreg.ce sym @reg_0 %1, %clk, %en reset %rst, %c0_i12_0 initial %0 : i12  
  %1 = comb.add %reg_0, %c1_i12 : i12
  hw.output %reg_0 : i12
}
hw.module @EnableIfElse(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %5, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  %true = hw.constant true
  %3 = comb.xor %en, %true : i1
  %c2_i8 = hw.constant 2 : i8
  %4 = comb.add %1, %c2_i8 : i8
  %5 = comb.mux %3, %4, %2 : i8
  hw.output %1 : i8
}
