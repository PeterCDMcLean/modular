hw.module @AsyncHighCounter(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c2_i8 = hw.constant 2 : i8
  %reg_1 = seq.firreg %0 clock %clk reset async %rst, %c2_i8 preset 2 : i8
  %0 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_1 : i8
}
hw.module @AsyncLowCounter(in %clk : !seq.clock, in %rst_n : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %true = hw.constant true
  %0 = comb.xor %rst_n, %true : i1
  %reg_1 = seq.firreg %1 clock %clk reset async %0, %c3_i8 preset 3 : i8
  %1 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_1 : i8
}
hw.module @SyncLowCounter(in %clk : !seq.clock, in %rst_n : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c1_i8_0 = hw.constant 1 : i8
  %true = hw.constant true
  %0 = comb.xor %rst_n, %true : i1
  %1 = seq.initial() {
    %c1_i8_1 = hw.constant 1 : i8
    seq.yield %c1_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %2 = seq.compreg %3, %clk reset %0, %c1_i8_0 initial %1 : i8  
  %3 = comb.add %2, %c1_i8 : i8
  hw.output %2 : i8
}
hw.module @ResetTop(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %true = hw.constant true
  %0 = comb.xor %rst, %true : i1
  %low.out = hw.instance "low" @SyncLowCounter(clk: %clk: !seq.clock, rst_n: %0: i1) -> (out: i8)
  hw.output %low.out : i8
}
