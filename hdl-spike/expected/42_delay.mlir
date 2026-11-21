hw.module @NextDelay(in %din : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %din, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %3 = seq.compreg %1, %clk reset %rst, %c0_i8_2 initial %2 : i8  
  hw.output %3 : i8
}
hw.module @PastDelay(in %din : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %din, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %3 = seq.compreg %1, %clk reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %3, %clk reset %rst, %c0_i8_4 initial %4 : i8  
  hw.output %5 : i8
}
