hw.module @MixedEnable(in %en : i1, in %other : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = comb.mux %en, %3, %2 : i8
  %2 = seq.compreg %5, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %3 = comb.add %2, %c1_i8 : i8
  %c2_i8 = hw.constant 2 : i8
  %4 = comb.add %2, %c2_i8 : i8
  %5 = comb.mux %other, %4, %1 : i8
  hw.output %2 : i8
}
hw.module @NestedMixedEnable(in %en : i1, in %mode : i1, in %other : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = comb.mux %en, %3, %2 : i8
  %2 = seq.compreg %6, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %3 = comb.add %2, %c1_i8 : i8
  %4 = comb.and %mode, %other : i1
  %c3_i8 = hw.constant 3 : i8
  %5 = comb.add %2, %c3_i8 : i8
  %6 = comb.mux %4, %5, %1 : i8
  hw.output %2 : i8
}
