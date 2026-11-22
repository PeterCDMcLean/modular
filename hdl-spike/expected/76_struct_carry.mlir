hw.module @LogicStructCarry(in %count : i64, in %init : i8, in %init_xz : i8, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c5_i4 = hw.constant 5 : i4
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_17 = hw.constant 0 : i64
    seq.yield %c0_i64_17 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %30, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_17 = hw.constant false
    seq.yield %false_17 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %34, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %24, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %25, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i4 = hw.constant 0 : i4
  %c0_i4_5 = hw.constant 0 : i4
  %8 = seq.initial() {
    %c0_i4_17 = hw.constant 0 : i4
    seq.yield %c0_i4_17 : i4
  } : () -> !seq.immutable<i4>
  %9 = seq.compreg %26, %clk reset %rst, %c0_i4_5 initial %8 : i4  
  %10 = comb.icmp ult %1, %count : i64
  %11 = comb.and %3, %10 : i1
  %12 = comb.or %7, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %13 = comb.xor %5, %c-1_i8 : i8
  %14 = comb.or %7, %13 : i8
  %c-1_i8_6 = hw.constant -1 : i8
  %15 = comb.xor %wd, %c-1_i8_6 : i8
  %16 = comb.or %wd_xz, %15 : i8
  %17 = comb.and %12, %14 : i8
  %18 = comb.and %17, %16 : i8
  %19 = comb.or %5, %wd : i8
  %20 = comb.mux %11, %19, %5 : i8
  %21 = comb.mux %11, %18, %7 : i8
  %c1_i4 = hw.constant 1 : i4
  %22 = comb.add %9, %c1_i4 : i4
  %23 = comb.mux %11, %22, %9 : i4
  %24 = comb.mux %3, %20, %init : i8
  %25 = comb.mux %3, %21, %init_xz : i8
  %26 = comb.mux %3, %23, %c5_i4 : i4
  %c1_i64 = hw.constant 1 : i64
  %27 = comb.add %1, %c1_i64 : i64
  %c0_i64_7 = hw.constant 0 : i64
  %28 = comb.icmp eq %27, %count : i64
  %29 = comb.and %11, %28 : i1
  %30 = comb.mux %11, %27, %c0_i64_7 : i64
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %31 = seq.initial() {
    %false_17 = hw.constant false
    seq.yield %false_17 : i1
  } : () -> !seq.immutable<i1>
  %32 = seq.compreg %29, %clk reset %rst, %false_9 initial %31 : i1  
  %true = hw.constant true
  %33 = comb.xor %29, %true : i1
  %true_10 = hw.constant true
  %34 = comb.mux %3, %33, %true_10 : i1
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %35 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %36 = seq.compreg %39, %clk reset %rst, %c0_i8_12 initial %35 : i8  
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %37 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %38 = seq.compreg %40, %clk reset %rst, %c0_i8_14 initial %37 : i8  
  %39 = comb.mux %32, %5, %36 : i8
  %40 = comb.mux %32, %7, %38 : i8
  %c0_i4_15 = hw.constant 0 : i4
  %c0_i4_16 = hw.constant 0 : i4
  %41 = seq.initial() {
    %c0_i4_17 = hw.constant 0 : i4
    seq.yield %c0_i4_17 : i4
  } : () -> !seq.immutable<i4>
  %reg_1 = seq.compreg.ce sym @reg_1 %9, %clk, %32 reset %rst, %c0_i4_16 initial %41 : i4  
  hw.output %36, %38 : i8, i8
}
hw.module @StructCarry(in %count : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c2_i8 = hw.constant 2 : i8
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
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %14, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %15, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %10 = comb.add %5, %wd : i8
  %11 = comb.mux %9, %10, %5 : i8
  %c3_i8 = hw.constant 3 : i8
  %12 = comb.add %7, %c3_i8 : i8
  %13 = comb.mux %9, %12, %7 : i8
  %14 = comb.mux %3, %11, %wd : i8
  %15 = comb.mux %3, %13, %c2_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %16 = comb.add %1, %c1_i64 : i64
  %c0_i64_5 = hw.constant 0 : i64
  %17 = comb.icmp eq %16, %count : i64
  %18 = comb.and %9, %17 : i1
  %19 = comb.mux %9, %16, %c0_i64_5 : i64
  %false_6 = hw.constant false
  %false_7 = hw.constant false
  %20 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %21 = seq.compreg %18, %clk reset %rst, %false_7 initial %20 : i1  
  %true = hw.constant true
  %22 = comb.xor %18, %true : i1
  %true_8 = hw.constant true
  %23 = comb.mux %3, %22, %true_8 : i1
  %c0_i8_9 = hw.constant 0 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %24 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %21 reset %rst, %c0_i8_10 initial %24 : i8  
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %25 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %7, %clk, %21 reset %rst, %c0_i8_12 initial %25 : i8  
  hw.output %reg_0 : i8
}
