hw.module @Counter(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.compreg %1, %clk reset %rst, %c0_i8_0 : i8  
  %c1_i8 = hw.constant 1 : i8
  %1 = comb.add %0, %c1_i8 : i8
  hw.output %0 : i8
}
