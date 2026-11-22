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
hw.module @TwoDomainChildren(in %en_a : i1, in %en_b : i1, in %clk_run_a : !seq.clock, in %rst_run_a : i1, in %clk_run_b : !seq.clock, in %rst_run_b : i1, out run_a_out : i8, out run_b_out : i8) {
  %a.out = hw.instance "a" @ChildCounter(en: %en_a: i1, clk: %clk_run_a: !seq.clock, rst: %rst_run_a: i1) -> (out: i8)
  %b.out = hw.instance "b" @ChildCounter(en: %en_b: i1, clk: %clk_run_b: !seq.clock, rst: %rst_run_b: i1) -> (out: i8)
  hw.output %a.out, %b.out : i8, i8
}
