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
hw.module @LogicReturn(in %sel : i1, in %a : i8, in %a_xz : i8, in %b : i8, in %b_xz : i8, out out : i8, out out_xz : i8) {
  %true = hw.constant true
  %0 = comb.xor %sel, %true : i1
  %1 = comb.mux %sel, %a, %b : i8
  %2 = comb.mux %sel, %a_xz, %b_xz : i8
  hw.output %1, %2 : i8, i8
}
hw.module @ReturnFallthrough(in %sel : i1, in %a : i8, in %b : i8, out out : i8) {
  %0 = comb.mux %sel, %a, %b : i8
  hw.output %0 : i8
}
hw.module @ReturnInstance(in %sel : i1, in %a : i8, in %b : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %cell.out = hw.instance "cell" @AccCell(delta: %2: i8, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %c0_i8 = hw.constant 0 : i8
  %0 = comb.mux %sel, %cell.out, %c0_i8 : i8
  %true = hw.constant true
  %1 = comb.xor %sel, %true : i1
  %2 = comb.mux %1, %b, %a : i8
  %c0_i8_0 = hw.constant 0 : i8
  %3 = comb.mux %1, %cell.out, %c0_i8_0 : i8
  %4 = comb.mux %sel, %0, %3 : i8
  hw.output %4 : i8
}
hw.module @ReturnMux(in %sel : i1, in %a : i8, in %b : i8, out out : i8) {
  %true = hw.constant true
  %0 = comb.xor %sel, %true : i1
  %1 = comb.mux %sel, %a, %b : i8
  hw.output %1 : i8
}
