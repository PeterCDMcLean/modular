hw.module @NestedAccum(in %outer : i64, in %inner : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_16 = hw.constant 0 : i64
    seq.yield %c0_i64_16 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %23, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %27, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %28, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %outer : i64
  %7 = comb.and %3, %6 : i1
  %c0_i64_4 = hw.constant 0 : i64
  %c0_i64_5 = hw.constant 0 : i64
  %8 = seq.initial() {
    %c0_i64_16 = hw.constant 0 : i64
    seq.yield %c0_i64_16 : i64
  } : () -> !seq.immutable<i64>
  %9 = seq.compreg %18, %clk reset %rst, %c0_i64_5 initial %8 : i64  
  %10 = comb.icmp ult %9, %inner : i64
  %11 = comb.and %7, %10 : i1
  %12 = comb.add %5, %wd : i8
  %13 = comb.mux %11, %12, %5 : i8
  %c1_i64 = hw.constant 1 : i64
  %14 = comb.add %9, %c1_i64 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %15 = comb.icmp eq %14, %inner : i64
  %16 = comb.and %11, %15 : i1
  %17 = comb.mux %16, %c0_i64_6, %14 : i64
  %18 = comb.mux %11, %17, %c0_i64_6 : i64
  %c1_i64_7 = hw.constant 1 : i64
  %19 = comb.add %1, %c1_i64_7 : i64
  %c0_i64_8 = hw.constant 0 : i64
  %20 = comb.icmp eq %19, %outer : i64
  %21 = comb.and %16, %20 : i1
  %22 = comb.mux %21, %c0_i64_8, %19 : i64
  %23 = comb.mux %16, %22, %1 : i64
  %false_9 = hw.constant false
  %false_10 = hw.constant false
  %24 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %25 = seq.compreg %21, %clk reset %rst, %false_10 initial %24 : i1  
  %true = hw.constant true
  %26 = comb.xor %21, %true : i1
  %true_11 = hw.constant true
  %27 = comb.mux %3, %26, %true_11 : i1
  %28 = comb.mux %3, %13, %c0_i8 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %29 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %25 reset %rst, %c0_i8_13 initial %29 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %30 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %31, %clk, %25 reset %rst, %c0_i8_15 initial %30 : i8  
  %31 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
hw.module @NestedLogicAccum(in %outer : i64, in %inner : i64, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_20 = hw.constant 0 : i64
    seq.yield %c0_i64_20 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %33, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_20 = hw.constant false
    seq.yield %false_20 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %37, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %38, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %39, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %8 = comb.icmp ult %1, %outer : i64
  %9 = comb.and %3, %8 : i1
  %c0_i64_5 = hw.constant 0 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %10 = seq.initial() {
    %c0_i64_20 = hw.constant 0 : i64
    seq.yield %c0_i64_20 : i64
  } : () -> !seq.immutable<i64>
  %11 = seq.compreg %28, %clk reset %rst, %c0_i64_6 initial %10 : i64  
  %12 = comb.icmp ult %11, %inner : i64
  %13 = comb.and %9, %12 : i1
  %14 = comb.or %7, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %15 = comb.xor %5, %c-1_i8 : i8
  %16 = comb.or %7, %15 : i8
  %c-1_i8_7 = hw.constant -1 : i8
  %17 = comb.xor %wd, %c-1_i8_7 : i8
  %18 = comb.or %wd_xz, %17 : i8
  %19 = comb.and %14, %16 : i8
  %20 = comb.and %19, %18 : i8
  %21 = comb.or %5, %wd : i8
  %22 = comb.mux %13, %21, %5 : i8
  %23 = comb.mux %13, %20, %7 : i8
  %c1_i64 = hw.constant 1 : i64
  %24 = comb.add %11, %c1_i64 : i64
  %c0_i64_8 = hw.constant 0 : i64
  %25 = comb.icmp eq %24, %inner : i64
  %26 = comb.and %13, %25 : i1
  %27 = comb.mux %26, %c0_i64_8, %24 : i64
  %28 = comb.mux %13, %27, %c0_i64_8 : i64
  %c1_i64_9 = hw.constant 1 : i64
  %29 = comb.add %1, %c1_i64_9 : i64
  %c0_i64_10 = hw.constant 0 : i64
  %30 = comb.icmp eq %29, %outer : i64
  %31 = comb.and %26, %30 : i1
  %32 = comb.mux %31, %c0_i64_10, %29 : i64
  %33 = comb.mux %26, %32, %1 : i64
  %false_11 = hw.constant false
  %false_12 = hw.constant false
  %34 = seq.initial() {
    %false_20 = hw.constant false
    seq.yield %false_20 : i1
  } : () -> !seq.immutable<i1>
  %35 = seq.compreg %31, %clk reset %rst, %false_12 initial %34 : i1  
  %true = hw.constant true
  %36 = comb.xor %31, %true : i1
  %true_13 = hw.constant true
  %37 = comb.mux %3, %36, %true_13 : i1
  %38 = comb.mux %3, %22, %wd : i8
  %39 = comb.mux %3, %23, %wd_xz : i8
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %40 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %41 = seq.compreg %44, %clk reset %rst, %c0_i8_15 initial %40 : i8  
  %c0_i8_16 = hw.constant 0 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %42 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %43 = seq.compreg %45, %clk reset %rst, %c0_i8_17 initial %42 : i8  
  %44 = comb.mux %35, %5, %41 : i8
  %45 = comb.mux %35, %7, %43 : i8
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_18 = hw.constant 0 : i8
  %c0_i8_19 = hw.constant 0 : i8
  %46 = seq.initial() {
    %c0_i8_20 = hw.constant 0 : i8
    seq.yield %c0_i8_20 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %47, %clk, %35 reset %rst, %c0_i8_19 initial %46 : i8  
  %47 = comb.add %reg_1, %c1_i8 : i8
  hw.output %41, %43 : i8, i8
}
