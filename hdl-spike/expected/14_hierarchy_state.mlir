hw.module @ChildCounter(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %1, %clk, %en reset %rst, %c0_i8_0 initial %0 : i8  
  %1 = comb.add %reg_0, %c1_i8 : i8
  hw.output %reg_0 : i8
}
hw.module @Parent(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %child.out = hw.instance "child" @ChildCounter(en: %en: i1, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  hw.output %child.out : i8
}
