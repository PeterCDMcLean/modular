hw.module @LogicNextDelay(in %din : i8, in %din_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %din, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %3 = seq.compreg %din_xz, %clk reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %1, %clk reset %rst, %c0_i8_4 initial %4 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %c0_i8_6 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %3, %clk reset %rst, %c0_i8_6 initial %6 : i8  
  hw.output %5, %7 : i8, i8
}
hw.module @LogicPastDelay(in %din : i8, in %din_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_11 = hw.constant 0 : i8
    seq.yield %c0_i8_11 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %din, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_11 = hw.constant 0 : i8
    seq.yield %c0_i8_11 : i8
  } : () -> !seq.immutable<i8>
  %3 = seq.compreg %din_xz, %clk reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_11 = hw.constant 0 : i8
    seq.yield %c0_i8_11 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %1, %clk reset %rst, %c0_i8_4 initial %4 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %c0_i8_6 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_11 = hw.constant 0 : i8
    seq.yield %c0_i8_11 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %3, %clk reset %rst, %c0_i8_6 initial %6 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %c0_i8_8 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_11 = hw.constant 0 : i8
    seq.yield %c0_i8_11 : i8
  } : () -> !seq.immutable<i8>
  %9 = seq.compreg %5, %clk reset %rst, %c0_i8_8 initial %8 : i8  
  %c0_i8_9 = hw.constant 0 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_11 = hw.constant 0 : i8
    seq.yield %c0_i8_11 : i8
  } : () -> !seq.immutable<i8>
  %11 = seq.compreg %7, %clk reset %rst, %c0_i8_10 initial %10 : i8  
  hw.output %9, %11 : i8, i8
}
