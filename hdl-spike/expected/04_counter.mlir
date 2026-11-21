hw.module @Counter(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %c1_i8 = hw.constant 1 : i8
  %2 = comb.add %1, %c1_i8 : i8
  hw.output %1 : i8
}
