hw.module @ConditionalReturnMethod(in %count : i64, in %en : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_13 = hw.constant 0 : i64
    seq.yield %c0_i64_13 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %24, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %28, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %19, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %20, %clk reset %rst, %c0_i8_5 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %true = hw.constant true
  %10 = comb.xor %en, %true : i1
  %11 = comb.and %9, %en : i1
  %12 = comb.mux %11, %wd, %7 : i8
  %13 = comb.add %5, %12 : i8
  %14 = comb.mux %9, %13, %5 : i8
  %15 = comb.add %7, %wd : i8
  %16 = comb.mux %9, %15, %7 : i8
  %17 = comb.add %14, %16 : i8
  %18 = comb.mux %9, %17, %14 : i8
  %19 = comb.mux %3, %18, %c0_i8 : i8
  %20 = comb.mux %3, %16, %wd : i8
  %c1_i64 = hw.constant 1 : i64
  %21 = comb.add %1, %c1_i64 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %22 = comb.icmp eq %21, %count : i64
  %23 = comb.and %9, %22 : i1
  %24 = comb.mux %9, %21, %c0_i64_6 : i64
  %false_7 = hw.constant false
  %false_8 = hw.constant false
  %25 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %26 = seq.compreg %23, %clk reset %rst, %false_8 initial %25 : i1  
  %true_9 = hw.constant true
  %27 = comb.xor %23, %true_9 : i1
  %true_10 = hw.constant true
  %28 = comb.mux %3, %27, %true_10 : i1
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %29 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %26 reset %rst, %c0_i8_12 initial %29 : i8  
  hw.output %reg_0 : i8
}
hw.module @LogicValueMethod(in %count : i64, in %init : i8, in %init_xz : i8, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_20 = hw.constant 0 : i64
    seq.yield %c0_i64_20 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %41, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_20 = hw.constant false
    seq.yield %false_20 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %45, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %34, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %35, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %c0_i8_6 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %9 = seq.compreg %36, %clk reset %rst, %c0_i8_6 initial %8 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %c0_i8_8 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %11 = seq.compreg %37, %clk reset %rst, %c0_i8_8 initial %10 : i8  
  %12 = comb.icmp ult %1, %count : i64
  %13 = comb.and %3, %12 : i1
  %14 = comb.or %7, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %15 = comb.xor %5, %c-1_i8 : i8
  %16 = comb.or %7, %15 : i8
  %c-1_i8_9 = hw.constant -1 : i8
  %17 = comb.xor %wd, %c-1_i8_9 : i8
  %18 = comb.or %wd_xz, %17 : i8
  %19 = comb.and %14, %16 : i8
  %20 = comb.and %19, %18 : i8
  %21 = comb.or %5, %wd : i8
  %22 = comb.mux %13, %21, %5 : i8
  %23 = comb.mux %13, %20, %7 : i8
  %24 = comb.or %11, %23 : i8
  %c-1_i8_10 = hw.constant -1 : i8
  %25 = comb.xor %9, %c-1_i8_10 : i8
  %26 = comb.or %11, %25 : i8
  %c-1_i8_11 = hw.constant -1 : i8
  %27 = comb.xor %22, %c-1_i8_11 : i8
  %28 = comb.or %23, %27 : i8
  %29 = comb.and %24, %26 : i8
  %30 = comb.and %29, %28 : i8
  %31 = comb.or %9, %22 : i8
  %32 = comb.mux %13, %31, %9 : i8
  %33 = comb.mux %13, %30, %11 : i8
  %34 = comb.mux %3, %22, %init : i8
  %35 = comb.mux %3, %23, %init_xz : i8
  %36 = comb.mux %3, %32, %init : i8
  %37 = comb.mux %3, %33, %init_xz : i8
  %c1_i64 = hw.constant 1 : i64
  %38 = comb.add %1, %c1_i64 : i64
  %c0_i64_12 = hw.constant 0 : i64
  %39 = comb.icmp eq %38, %count : i64
  %40 = comb.and %13, %39 : i1
  %41 = comb.mux %13, %38, %c0_i64_12 : i64
  %false_13 = hw.constant false
  %false_14 = hw.constant false
  %42 = seq.initial() {
    %false_20 = hw.constant false
    seq.yield %false_20 : i1
  } : () -> !seq.immutable<i1>
  %43 = seq.compreg %40, %clk reset %rst, %false_14 initial %42 : i1  
  %true = hw.constant true
  %44 = comb.xor %40, %true : i1
  %true_15 = hw.constant true
  %45 = comb.mux %3, %44, %true_15 : i1
  %c0_i8_16 = hw.constant 0 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %46 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %47 = seq.compreg %50, %clk reset %rst, %c0_i8_17 initial %46 : i8  
  %c0_i8_18 = hw.constant 0 : i8
  %c0_i8_19 = hw.constant 0 : i8
  %48 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %49 = seq.compreg %51, %clk reset %rst, %c0_i8_19 initial %48 : i8  
  %50 = comb.mux %43, %9, %47 : i8
  %51 = comb.mux %43, %11, %49 : i8
  hw.output %47, %49 : i8, i8
}
