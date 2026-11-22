hw.module @AsyncLowChild(in %clk : !seq.clock, in %rst_n : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %true = hw.constant true
  %0 = comb.xor %rst_n, %true : i1
  %reg_1 = seq.firreg %1 clock %clk reset async %0, %c3_i8 preset 3 : i8
  %1 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_1 : i8
}
hw.module @SyncHighChild(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %0 = seq.initial() {
    %c5_i8_0 = hw.constant 5 : i8
    seq.yield %c5_i8_0 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c5_i8 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  hw.output %1 : i8
}
hw.module @ResetParentHigh(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %true = hw.constant true
  %0 = comb.xor %rst, %true : i1
  %a.out = hw.instance "a" @AsyncLowChild(clk: %clk: !seq.clock, rst_n: %0: i1) -> (out: i8)
  %b.out = hw.instance "b" @SyncHighChild(clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %1 = comb.xor %a.out, %b.out : i8
  hw.output %1 : i8
}
hw.module @ResetParentLow(in %clk : !seq.clock, in %rst_n : i1, out out : i8) {
  %a.out = hw.instance "a" @AsyncLowChild(clk: %clk: !seq.clock, rst_n: %rst_n: i1) -> (out: i8)
  %true = hw.constant true
  %0 = comb.xor %rst_n, %true : i1
  %b.out = hw.instance "b" @SyncHighChild(clk: %clk: !seq.clock, rst: %0: i1) -> (out: i8)
  %1 = comb.xor %a.out, %b.out : i8
  hw.output %1 : i8
}
