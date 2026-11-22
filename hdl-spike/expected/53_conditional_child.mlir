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
  %cell.out = hw.instance "cell" @AccCell(delta: %11: i8, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %c0_i8 = hw.constant 0 : i8
  %0 = comb.mux %sel_a, %cell.out, %c0_i8 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %2 = comb.mux %sel_a, %0, %3 : i8
  %3 = seq.compreg %13, %clk reset %rst, %c0_i8_1 initial %1 : i8  
  %true = hw.constant true
  %4 = comb.xor %sel_a, %true : i1
  %5 = comb.and %4, %sel_b : i1
  %6 = comb.mux %5, %b, %a : i8
  %c0_i8_2 = hw.constant 0 : i8
  %7 = comb.mux %5, %cell.out, %c0_i8_2 : i8
  %8 = comb.mux %5, %7, %2 : i8
  %true_3 = hw.constant true
  %9 = comb.xor %sel_b, %true_3 : i1
  %10 = comb.and %4, %9 : i1
  %11 = comb.mux %10, %c, %6 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %12 = comb.mux %10, %cell.out, %c0_i8_4 : i8
  %13 = comb.mux %10, %12, %8 : i8
  hw.output %3 : i8
}
hw.module @ConditionalTick(in %sel : i1, in %a : i8, in %b : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %cell.out = hw.instance "cell" @AccCell(delta: %5: i8, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %c0_i8 = hw.constant 0 : i8
  %0 = comb.mux %sel, %cell.out, %c0_i8 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %2 = comb.mux %sel, %0, %3 : i8
  %3 = seq.compreg %7, %clk reset %rst, %c0_i8_1 initial %1 : i8  
  %true = hw.constant true
  %4 = comb.xor %sel, %true : i1
  %5 = comb.mux %4, %b, %a : i8
  %c0_i8_2 = hw.constant 0 : i8
  %6 = comb.mux %4, %cell.out, %c0_i8_2 : i8
  %7 = comb.mux %4, %6, %2 : i8
  hw.output %3 : i8
}
