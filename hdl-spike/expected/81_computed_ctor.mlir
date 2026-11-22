hw.module @ComputedCtorCarry(in %count : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c3_i8 = hw.constant 3 : i8
  %0 = comb.add %wd, %c3_i8 : i8
  %c5_i8 = hw.constant 5 : i8
  %1 = comb.add %c3_i8, %c5_i8 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %2 = seq.initial() {
    %c0_i64_13 = hw.constant 0 : i64
    seq.yield %c0_i64_13 : i64
  } : () -> !seq.immutable<i64>
  %3 = seq.compreg %21, %clk reset %rst, %c0_i64_0 initial %2 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %4 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %5 = seq.compreg %25, %clk reset %rst, %false_1 initial %4 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %16, %clk reset %rst, %c0_i8_2 initial %6 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %9 = seq.compreg %17, %clk reset %rst, %c0_i8_4 initial %8 : i8  
  %10 = comb.icmp ult %3, %count : i64
  %11 = comb.and %5, %10 : i1
  %12 = comb.add %7, %wd : i8
  %13 = comb.mux %11, %12, %7 : i8
  %c1_i8 = hw.constant 1 : i8
  %14 = comb.add %9, %c1_i8 : i8
  %15 = comb.mux %11, %14, %9 : i8
  %16 = comb.mux %5, %13, %0 : i8
  %17 = comb.mux %5, %15, %1 : i8
  %c1_i64 = hw.constant 1 : i64
  %18 = comb.add %3, %c1_i64 : i64
  %c0_i64_5 = hw.constant 0 : i64
  %19 = comb.icmp eq %18, %count : i64
  %20 = comb.and %11, %19 : i1
  %21 = comb.mux %11, %18, %c0_i64_5 : i64
  %false_6 = hw.constant false
  %false_7 = hw.constant false
  %22 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %23 = seq.compreg %20, %clk reset %rst, %false_7 initial %22 : i1  
  %true = hw.constant true
  %24 = comb.xor %20, %true : i1
  %true_8 = hw.constant true
  %25 = comb.mux %5, %24, %true_8 : i1
  %c0_i8_9 = hw.constant 0 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %26 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %7, %clk, %23 reset %rst, %c0_i8_10 initial %26 : i8  
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %27 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %9, %clk, %23 reset %rst, %c0_i8_12 initial %27 : i8  
  hw.output %reg_0 : i8
}
hw.module @LogicComputedCtor(in %count : i64, in %init : i8, in %init_xz : i8, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c2_i4 = hw.constant 2 : i4
  %0 = comb.or %init_xz, %init_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %1 = comb.xor %init, %c-1_i8 : i8
  %2 = comb.or %init_xz, %1 : i8
  %c-1_i8_0 = hw.constant -1 : i8
  %3 = comb.xor %init, %c-1_i8_0 : i8
  %4 = comb.or %init_xz, %3 : i8
  %5 = comb.and %0, %2 : i8
  %6 = comb.and %5, %4 : i8
  %7 = comb.or %init, %init : i8
  %c3_i4 = hw.constant 3 : i4
  %8 = comb.add %c2_i4, %c3_i4 : i4
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_1 = hw.constant 0 : i64
  %9 = seq.initial() {
    %c0_i64_19 = hw.constant 0 : i64
    seq.yield %c0_i64_19 : i64
  } : () -> !seq.immutable<i64>
  %10 = seq.compreg %37, %clk reset %rst, %c0_i64_1 initial %9 : i64  
  %false = hw.constant false
  %false_2 = hw.constant false
  %11 = seq.initial() {
    %false_19 = hw.constant false
    seq.yield %false_19 : i1
  } : () -> !seq.immutable<i1>
  %12 = seq.compreg %41, %clk reset %rst, %false_2 initial %11 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %13 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %14 = seq.compreg %31, %clk reset %rst, %c0_i8_3 initial %13 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %15 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %16 = seq.compreg %32, %clk reset %rst, %c0_i8_5 initial %15 : i8  
  %c0_i4 = hw.constant 0 : i4
  %c0_i4_6 = hw.constant 0 : i4
  %17 = seq.initial() {
    %c0_i4_19 = hw.constant 0 : i4
    seq.yield %c0_i4_19 : i4
  } : () -> !seq.immutable<i4>
  %18 = seq.compreg %33, %clk reset %rst, %c0_i4_6 initial %17 : i4  
  %19 = comb.icmp ult %10, %count : i64
  %20 = comb.and %12, %19 : i1
  %21 = comb.or %16, %wd_xz : i8
  %c-1_i8_7 = hw.constant -1 : i8
  %22 = comb.xor %14, %c-1_i8_7 : i8
  %23 = comb.or %16, %22 : i8
  %c-1_i8_8 = hw.constant -1 : i8
  %24 = comb.xor %wd, %c-1_i8_8 : i8
  %25 = comb.or %wd_xz, %24 : i8
  %26 = comb.and %21, %23 : i8
  %27 = comb.and %26, %25 : i8
  %28 = comb.or %14, %wd : i8
  %c1_i4 = hw.constant 1 : i4
  %29 = comb.add %18, %c1_i4 : i4
  %30 = comb.mux %20, %29, %18 : i4
  %31 = comb.mux %12, %14, %7 : i8
  %32 = comb.mux %12, %16, %6 : i8
  %33 = comb.mux %12, %30, %8 : i4
  %c1_i64 = hw.constant 1 : i64
  %34 = comb.add %10, %c1_i64 : i64
  %c0_i64_9 = hw.constant 0 : i64
  %35 = comb.icmp eq %34, %count : i64
  %36 = comb.and %20, %35 : i1
  %37 = comb.mux %20, %34, %c0_i64_9 : i64
  %false_10 = hw.constant false
  %false_11 = hw.constant false
  %38 = seq.initial() {
    %false_19 = hw.constant false
    seq.yield %false_19 : i1
  } : () -> !seq.immutable<i1>
  %39 = seq.compreg %36, %clk reset %rst, %false_11 initial %38 : i1  
  %true = hw.constant true
  %40 = comb.xor %36, %true : i1
  %true_12 = hw.constant true
  %41 = comb.mux %12, %40, %true_12 : i1
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %42 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %43 = seq.compreg %46, %clk reset %rst, %c0_i8_14 initial %42 : i8  
  %c0_i8_15 = hw.constant 0 : i8
  %c0_i8_16 = hw.constant 0 : i8
  %44 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %45 = seq.compreg %47, %clk reset %rst, %c0_i8_16 initial %44 : i8  
  %46 = comb.mux %39, %14, %43 : i8
  %47 = comb.mux %39, %16, %45 : i8
  %c0_i4_17 = hw.constant 0 : i4
  %c0_i4_18 = hw.constant 0 : i4
  %48 = seq.initial() {
    %c0_i4_19 = hw.constant 0 : i4
    seq.yield %c0_i4_19 : i4
  } : () -> !seq.immutable<i4>
  %reg_1 = seq.compreg.ce sym @reg_1 %18, %clk, %39 reset %rst, %c0_i4_18 initial %48 : i4  
  hw.output %43, %45 : i8, i8
}
