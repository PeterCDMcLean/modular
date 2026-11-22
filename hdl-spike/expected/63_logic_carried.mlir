hw.module @RuntimeForLogicAccum(in %count : i64, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_16 = hw.constant 0 : i64
    seq.yield %c0_i64_16 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %21, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %29, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %26, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %27, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %10 = comb.or %7, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %11 = comb.xor %5, %c-1_i8 : i8
  %12 = comb.or %7, %11 : i8
  %c-1_i8_5 = hw.constant -1 : i8
  %13 = comb.xor %wd, %c-1_i8_5 : i8
  %14 = comb.or %wd_xz, %13 : i8
  %15 = comb.and %10, %12 : i8
  %16 = comb.and %15, %14 : i8
  %17 = comb.or %5, %wd : i8
  %18 = comb.mux %9, %17, %5 : i8
  %19 = comb.mux %9, %16, %7 : i8
  %c1_i64 = hw.constant 1 : i64
  %20 = comb.add %1, %c1_i64 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %21 = comb.mux %9, %20, %c0_i64_6 : i64
  %22 = comb.icmp eq %20, %count : i64
  %23 = comb.and %9, %22 : i1
  %false_7 = hw.constant false
  %false_8 = hw.constant false
  %24 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %25 = seq.compreg %23, %clk reset %rst, %false_8 initial %24 : i1  
  %26 = comb.mux %3, %18, %wd : i8
  %27 = comb.mux %3, %19, %wd_xz : i8
  %true = hw.constant true
  %28 = comb.xor %23, %true : i1
  %true_9 = hw.constant true
  %29 = comb.mux %3, %28, %true_9 : i1
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %30 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %31 = seq.compreg %34, %clk reset %rst, %c0_i8_11 initial %30 : i8  
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %32 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %33 = seq.compreg %35, %clk reset %rst, %c0_i8_13 initial %32 : i8  
  %34 = comb.mux %25, %5, %31 : i8
  %35 = comb.mux %25, %7, %33 : i8
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %36 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %37, %clk, %25 reset %rst, %c0_i8_15 initial %36 : i8  
  %37 = comb.add %reg_1, %c1_i8 : i8
  hw.output %31, %33 : i8, i8
}
hw.module @RuntimeWhileLogicAccum(in %count : i64, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_16 = hw.constant 0 : i64
    seq.yield %c0_i64_16 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %21, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %29, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %26, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %27, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %10 = comb.or %7, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %11 = comb.xor %5, %c-1_i8 : i8
  %12 = comb.or %7, %11 : i8
  %c-1_i8_5 = hw.constant -1 : i8
  %13 = comb.xor %wd, %c-1_i8_5 : i8
  %14 = comb.or %wd_xz, %13 : i8
  %15 = comb.and %10, %12 : i8
  %16 = comb.and %15, %14 : i8
  %17 = comb.or %5, %wd : i8
  %18 = comb.mux %9, %17, %5 : i8
  %19 = comb.mux %9, %16, %7 : i8
  %c1_i64 = hw.constant 1 : i64
  %20 = comb.add %1, %c1_i64 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %21 = comb.mux %9, %20, %c0_i64_6 : i64
  %22 = comb.icmp eq %20, %count : i64
  %23 = comb.and %9, %22 : i1
  %false_7 = hw.constant false
  %false_8 = hw.constant false
  %24 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %25 = seq.compreg %23, %clk reset %rst, %false_8 initial %24 : i1  
  %26 = comb.mux %3, %18, %wd : i8
  %27 = comb.mux %3, %19, %wd_xz : i8
  %true = hw.constant true
  %28 = comb.xor %23, %true : i1
  %true_9 = hw.constant true
  %29 = comb.mux %3, %28, %true_9 : i1
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %30 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %31 = seq.compreg %34, %clk reset %rst, %c0_i8_11 initial %30 : i8  
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %32 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %33 = seq.compreg %35, %clk reset %rst, %c0_i8_13 initial %32 : i8  
  %34 = comb.mux %25, %5, %31 : i8
  %35 = comb.mux %25, %7, %33 : i8
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %36 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %37, %clk, %25 reset %rst, %c0_i8_15 initial %36 : i8  
  %37 = comb.add %reg_1, %c1_i8 : i8
  hw.output %31, %33 : i8, i8
}
