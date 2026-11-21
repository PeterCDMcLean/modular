hw.module @DepCounter_16_4(in %clk : !seq.clock, in %rst : i1, out out : i20) {
  %c4_i20 = hw.constant 4 : i20
  %c0_i20 = hw.constant 0 : i20
  %c0_i20_0 = hw.constant 0 : i20
  %0 = seq.initial() {
    %c0_i20_1 = hw.constant 0 : i20
    seq.yield %c0_i20_1 : i20
  } : () -> !seq.immutable<i20>
  %1 = seq.compreg %2, %clk reset %rst, %c0_i20_0 initial %0 : i20  
  %2 = comb.add %1, %c4_i20 : i20
  hw.output %1 : i20
}
hw.module @DepCounter_8_1(in %clk : !seq.clock, in %rst : i1, out out : i9) {
  %c1_i9 = hw.constant 1 : i9
  %c0_i9 = hw.constant 0 : i9
  %c0_i9_0 = hw.constant 0 : i9
  %0 = seq.initial() {
    %c0_i9_1 = hw.constant 0 : i9
    seq.yield %c0_i9_1 : i9
  } : () -> !seq.immutable<i9>
  %1 = seq.compreg %2, %clk reset %rst, %c0_i9_0 initial %0 : i9  
  %2 = comb.add %1, %c1_i9 : i9
  hw.output %1 : i9
}
hw.module @DepTop(in %clk_run_a : !seq.clock, in %rst_run_a : i1, in %clk_run_b : !seq.clock, in %rst_run_b : i1, out run_a_out : i9, out run_b_out : i20) {
  %a.out = hw.instance "a" @DepCounter_8_1(clk: %clk_run_a: !seq.clock, rst: %rst_run_a: i1) -> (out: i9)
  %b.out = hw.instance "b" @DepCounter_16_4(clk: %clk_run_b: !seq.clock, rst: %rst_run_b: i1) -> (out: i20)
  hw.output %a.out, %b.out : i9, i20
}
