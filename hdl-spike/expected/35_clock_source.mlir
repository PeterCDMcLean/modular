hw.module @DivCounter(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %0 = seq.clock_div %clk by 2
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %2 = seq.compreg %3, %0 reset %rst, %c0_i8_0 initial %1 : i8  
  %3 = comb.add %2, %c1_i8 : i8
  hw.output %2 : i8
}
hw.module @ClockTop(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %child.out = hw.instance "child" @DivCounter(clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  hw.output %child.out : i8
}
