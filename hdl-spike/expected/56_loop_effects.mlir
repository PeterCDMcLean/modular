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
hw.module @LoopMemWrite(in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c4_i64 = hw.constant 4 : i64
  %c0_i64 = hw.constant 0 : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %en reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %en reset %rst, %c0_i8_1 initial %1 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %en reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %en reset %rst, %c0_i8_3 initial %3 : i8  
  %c1_i64 = hw.constant 1 : i64
  %c2_i64 = hw.constant 2 : i64
  %c3_i64 = hw.constant 3 : i64
  %c2_i64_4 = hw.constant 2 : i64
  hw.output %mem_0_2 : i8
}
hw.module @LoopSelectiveTick(in %delta : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c4_i64 = hw.constant 4 : i64
  %cell.out = hw.instance "cell" @AccCell(delta: %delta: i8, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %cell.out, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  hw.output %1 : i8
}
hw.module @LoopSum(in %a : i8, in %b : i8, out out : i8) {
  %c4_i64 = hw.constant 4 : i64
  %0 = comb.add %a, %b : i8
  %1 = comb.add %0, %b : i8
  %2 = comb.add %1, %b : i8
  %3 = comb.add %2, %b : i8
  hw.output %3 : i8
}
hw.module @WhileSum(in %a : i8, in %b : i8, out out : i8) {
  %0 = comb.add %a, %b : i8
  %1 = comb.add %0, %b : i8
  %2 = comb.add %1, %b : i8
  %3 = comb.add %2, %b : i8
  hw.output %3 : i8
}
