hw.module @EnableCounter(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i12) {
  %c1_i12 = hw.constant 1 : i12
  %c0_i12 = hw.constant 0 : i12
  %c0_i12_0 = hw.constant 0 : i12
  %0 = seq.initial() {
    %c0_i12_1 = hw.constant 0 : i12
    seq.yield %c0_i12_1 : i12
  } : () -> !seq.immutable<i12>
  %1 = seq.compreg %3, %clk reset %rst, %c0_i12_0 initial %0 : i12  
  %2 = comb.add %1, %c1_i12 : i12
  %3 = comb.mux %en, %2, %1 : i12
  hw.output %1 : i12
}
