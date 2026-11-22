hw.module @ConditionalMethodCarry(in %count : i64, in %en : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_17 = hw.constant 0 : i64
    seq.yield %c0_i64_17 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %25, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_17 = hw.constant false
    seq.yield %false_17 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %29, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %20, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %21, %clk reset %rst, %c0_i8_5 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %true = hw.constant true
  %10 = comb.xor %en, %true : i1
  %11 = comb.and %9, %en : i1
  %12 = comb.add %5, %wd : i8
  %13 = comb.mux %11, %12, %5 : i8
  %c1_i8 = hw.constant 1 : i8
  %14 = comb.add %7, %c1_i8 : i8
  %15 = comb.mux %11, %14, %7 : i8
  %true_6 = hw.constant true
  %16 = comb.xor %en, %true_6 : i1
  %17 = comb.and %9, %16 : i1
  %c1_i8_7 = hw.constant 1 : i8
  %18 = comb.sub %13, %c1_i8_7 : i8
  %19 = comb.mux %17, %18, %13 : i8
  %20 = comb.mux %3, %19, %wd : i8
  %21 = comb.mux %3, %15, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %22 = comb.add %1, %c1_i64 : i64
  %c0_i64_8 = hw.constant 0 : i64
  %23 = comb.icmp eq %22, %count : i64
  %24 = comb.and %9, %23 : i1
  %25 = comb.mux %9, %22, %c0_i64_8 : i64
  %false_9 = hw.constant false
  %false_10 = hw.constant false
  %26 = seq.initial() {
    %false_17 = hw.constant false
    seq.yield %false_17 : i1
  } : () -> !seq.immutable<i1>
  %27 = seq.compreg %24, %clk reset %rst, %false_10 initial %26 : i1  
  %true_11 = hw.constant true
  %28 = comb.xor %24, %true_11 : i1
  %true_12 = hw.constant true
  %29 = comb.mux %3, %28, %true_12 : i1
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %30 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %27 reset %rst, %c0_i8_14 initial %30 : i8  
  %c0_i8_15 = hw.constant 0 : i8
  %c0_i8_16 = hw.constant 0 : i8
  %31 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %7, %clk, %27 reset %rst, %c0_i8_16 initial %31 : i8  
  hw.output %reg_0 : i8
}
hw.module @LocalStepCarry(in %count : i64, in %en : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_16 = hw.constant 0 : i64
    seq.yield %c0_i64_16 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %26, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %30, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %21, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %22, %clk reset %rst, %c0_i8_5 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %c2_i8 = hw.constant 2 : i8
  %10 = comb.add %wd, %c2_i8 : i8
  %true = hw.constant true
  %11 = comb.xor %en, %true : i1
  %12 = comb.and %9, %en : i1
  %13 = comb.add %5, %10 : i8
  %14 = comb.mux %12, %13, %5 : i8
  %c1_i8 = hw.constant 1 : i8
  %15 = comb.add %7, %c1_i8 : i8
  %16 = comb.mux %12, %15, %7 : i8
  %true_6 = hw.constant true
  %17 = comb.xor %en, %true_6 : i1
  %18 = comb.and %9, %17 : i1
  %19 = comb.sub %14, %10 : i8
  %20 = comb.mux %18, %19, %14 : i8
  %21 = comb.mux %3, %20, %wd : i8
  %22 = comb.mux %3, %16, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %23 = comb.add %1, %c1_i64 : i64
  %c0_i64_7 = hw.constant 0 : i64
  %24 = comb.icmp eq %23, %count : i64
  %25 = comb.and %9, %24 : i1
  %26 = comb.mux %9, %23, %c0_i64_7 : i64
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %27 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %28 = seq.compreg %25, %clk reset %rst, %false_9 initial %27 : i1  
  %true_10 = hw.constant true
  %29 = comb.xor %25, %true_10 : i1
  %true_11 = hw.constant true
  %30 = comb.mux %3, %29, %true_11 : i1
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %31 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %28 reset %rst, %c0_i8_13 initial %31 : i8  
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %32 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %7, %clk, %28 reset %rst, %c0_i8_15 initial %32 : i8  
  hw.output %reg_0 : i8
}
