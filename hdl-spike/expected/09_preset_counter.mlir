hw.module @PresetCounter(in %clk : !seq.clock, in %rst : i1, out out : i12) {
  %c1_i12 = hw.constant 1 : i12
  %c0_i12 = hw.constant 0 : i12
  %c5_i12 = hw.constant 5 : i12
  %0 = seq.compreg %1, %clk reset %rst, %c5_i12 : i12  
  %1 = comb.add %0, %c1_i12 : i12
  hw.output %0 : i12
}
