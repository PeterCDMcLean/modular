hw.module @PresetCounter(in %clk : !seq.clock, in %rst : i1, out out : i12) {
  %c1_i12 = hw.constant 1 : i12
  %c0_i12 = hw.constant 0 : i12
  %c5_i12 = hw.constant 5 : i12
  %0 = seq.initial() {
    %c5_i12_0 = hw.constant 5 : i12
    seq.yield %c5_i12_0 : i12
  } : () -> !seq.immutable<i12>
  %1 = seq.compreg %2, %clk reset %rst, %c5_i12 initial %0 : i12  
  %2 = comb.add %1, %c1_i12 : i12
  hw.output %1 : i12
}
