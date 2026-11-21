hw.module @BitsCounter(in %clk : !seq.clock, out out : i12) {
  %c1_i12 = hw.constant 1 : i12
  %c0_i12 = hw.constant 0 : i12
  %0 = seq.compreg %1, %clk : i12  
  %1 = comb.add %0, %c1_i12 : i12
  hw.output %0 : i12
}
