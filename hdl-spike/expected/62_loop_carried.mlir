hw.module @RuntimeForAccum(in %count : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_12 = hw.constant 0 : i64
    seq.yield %c0_i64_12 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %14, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_12 = hw.constant false
    seq.yield %false_12 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %18, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_12 = hw.constant 0 : i8
    seq.yield %c0_i8_12 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %10, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %10 = comb.mux %3, %9, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %11 = comb.add %1, %c1_i64 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %12 = comb.icmp eq %11, %count : i64
  %13 = comb.and %7, %12 : i1
  %14 = comb.mux %7, %11, %c0_i64_4 : i64
  %false_5 = hw.constant false
  %false_6 = hw.constant false
  %15 = seq.initial() {
    %false_12 = hw.constant false
    seq.yield %false_12 : i1
  } : () -> !seq.immutable<i1>
  %16 = seq.compreg %13, %clk reset %rst, %false_6 initial %15 : i1  
  %true = hw.constant true
  %17 = comb.xor %13, %true : i1
  %true_7 = hw.constant true
  %18 = comb.mux %3, %17, %true_7 : i1
  %c0_i8_8 = hw.constant 0 : i8
  %c0_i8_9 = hw.constant 0 : i8
  %19 = seq.initial() {
    %c0_i8_12 = hw.constant 0 : i8
    seq.yield %c0_i8_12 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %16 reset %rst, %c0_i8_9 initial %19 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %20 = seq.initial() {
    %c0_i8_12 = hw.constant 0 : i8
    seq.yield %c0_i8_12 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %21, %clk, %16 reset %rst, %c0_i8_11 initial %20 : i8  
  %21 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
hw.module @RuntimeWhileAccum(in %count : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_12 = hw.constant 0 : i64
    seq.yield %c0_i64_12 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %14, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_12 = hw.constant false
    seq.yield %false_12 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %18, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_12 = hw.constant 0 : i8
    seq.yield %c0_i8_12 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %10, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %10 = comb.mux %3, %9, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %11 = comb.add %1, %c1_i64 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %12 = comb.icmp eq %11, %count : i64
  %13 = comb.and %7, %12 : i1
  %14 = comb.mux %7, %11, %c0_i64_4 : i64
  %false_5 = hw.constant false
  %false_6 = hw.constant false
  %15 = seq.initial() {
    %false_12 = hw.constant false
    seq.yield %false_12 : i1
  } : () -> !seq.immutable<i1>
  %16 = seq.compreg %13, %clk reset %rst, %false_6 initial %15 : i1  
  %true = hw.constant true
  %17 = comb.xor %13, %true : i1
  %true_7 = hw.constant true
  %18 = comb.mux %3, %17, %true_7 : i1
  %c0_i8_8 = hw.constant 0 : i8
  %c0_i8_9 = hw.constant 0 : i8
  %19 = seq.initial() {
    %c0_i8_12 = hw.constant 0 : i8
    seq.yield %c0_i8_12 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %16 reset %rst, %c0_i8_9 initial %19 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %20 = seq.initial() {
    %c0_i8_12 = hw.constant 0 : i8
    seq.yield %c0_i8_12 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %21, %clk, %16 reset %rst, %c0_i8_11 initial %20 : i8  
  %21 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
