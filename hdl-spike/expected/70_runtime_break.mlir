hw.module @RuntimeBreak(in %count : i64, in %stop : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_13 = hw.constant 0 : i64
    seq.yield %c0_i64_13 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %19, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %23, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %12, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %true = hw.constant true
  %10 = comb.xor %stop, %true : i1
  %11 = comb.and %7, %stop : i1
  %12 = comb.mux %3, %9, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %13 = comb.add %1, %c1_i64 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %14 = comb.and %7, %stop : i1
  %15 = comb.icmp eq %13, %count : i64
  %16 = comb.and %7, %15 : i1
  %17 = comb.or %16, %14 : i1
  %18 = comb.mux %14, %count, %13 : i64
  %19 = comb.mux %7, %18, %c0_i64_4 : i64
  %false_5 = hw.constant false
  %false_6 = hw.constant false
  %20 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %21 = seq.compreg %17, %clk reset %rst, %false_6 initial %20 : i1  
  %true_7 = hw.constant true
  %22 = comb.xor %17, %true_7 : i1
  %true_8 = hw.constant true
  %23 = comb.mux %3, %22, %true_8 : i1
  %c0_i8_9 = hw.constant 0 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %24 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %21 reset %rst, %c0_i8_10 initial %24 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %25 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %26, %clk, %21 reset %rst, %c0_i8_12 initial %25 : i8  
  %26 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
hw.module @RuntimeWhileBreak(in %count : i64, in %stop : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_13 = hw.constant 0 : i64
    seq.yield %c0_i64_13 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %19, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %23, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %12, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %true = hw.constant true
  %10 = comb.xor %stop, %true : i1
  %11 = comb.and %7, %stop : i1
  %12 = comb.mux %3, %9, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %13 = comb.add %1, %c1_i64 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %14 = comb.and %7, %stop : i1
  %15 = comb.icmp eq %13, %count : i64
  %16 = comb.and %7, %15 : i1
  %17 = comb.or %16, %14 : i1
  %18 = comb.mux %14, %count, %13 : i64
  %19 = comb.mux %7, %18, %c0_i64_4 : i64
  %false_5 = hw.constant false
  %false_6 = hw.constant false
  %20 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %21 = seq.compreg %17, %clk reset %rst, %false_6 initial %20 : i1  
  %true_7 = hw.constant true
  %22 = comb.xor %17, %true_7 : i1
  %true_8 = hw.constant true
  %23 = comb.mux %3, %22, %true_8 : i1
  %c0_i8_9 = hw.constant 0 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %24 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %21 reset %rst, %c0_i8_10 initial %24 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %25 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %26, %clk, %21 reset %rst, %c0_i8_12 initial %25 : i8  
  %26 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
