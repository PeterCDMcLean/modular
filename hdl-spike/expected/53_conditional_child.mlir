hw.module @AccCell(in %delta : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %2 = comb.add %1, %delta : i8
  hw.output %1 : i8
}
hw.module @ConditionalChain(in %sel_a : i1, in %sel_b : i1, in %a : i8, in %b : i8, in %c : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %cell.out = hw.instance "cell" @AccCell(delta: %10: i8, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %c0_i8 = hw.constant 0 : i8
  %0 = comb.mux %sel_a, %cell.out, %c0_i8 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %2 = seq.compreg %12, %clk reset %rst, %c0_i8_1 initial %1 : i8  
  %true = hw.constant true
  %3 = comb.xor %sel_a, %true : i1
  %4 = comb.and %3, %sel_b : i1
  %5 = comb.mux %4, %b, %a : i8
  %c0_i8_2 = hw.constant 0 : i8
  %6 = comb.mux %4, %cell.out, %c0_i8_2 : i8
  %7 = comb.mux %4, %6, %0 : i8
  %true_3 = hw.constant true
  %8 = comb.xor %sel_b, %true_3 : i1
  %9 = comb.and %3, %8 : i1
  %10 = comb.mux %9, %c, %5 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %11 = comb.mux %9, %cell.out, %c0_i8_4 : i8
  %12 = comb.mux %9, %11, %7 : i8
  hw.output %2 : i8
}
hw.module @ConditionalTick(in %sel : i1, in %a : i8, in %b : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %cell.out = hw.instance "cell" @AccCell(delta: %4: i8, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %c0_i8 = hw.constant 0 : i8
  %0 = comb.mux %sel, %cell.out, %c0_i8 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %2 = seq.compreg %6, %clk reset %rst, %c0_i8_1 initial %1 : i8  
  %true = hw.constant true
  %3 = comb.xor %sel, %true : i1
  %4 = comb.mux %3, %b, %a : i8
  %c0_i8_2 = hw.constant 0 : i8
  %5 = comb.mux %3, %cell.out, %c0_i8_2 : i8
  %6 = comb.mux %3, %5, %0 : i8
  hw.output %2 : i8
}
