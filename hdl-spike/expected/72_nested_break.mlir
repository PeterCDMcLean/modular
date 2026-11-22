hw.module @ElseIfBreak(in %count : i64, in %a : i1, in %b : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_15 = hw.constant 0 : i64
    seq.yield %c0_i64_15 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %27, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_15 = hw.constant false
    seq.yield %false_15 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %31, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_15 = hw.constant 0 : i8
    seq.yield %c0_i8_15 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %20, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %true = hw.constant true
  %8 = comb.xor %a, %true : i1
  %9 = comb.and %7, %a : i1
  %10 = comb.add %5, %wd : i8
  %11 = comb.mux %9, %10, %5 : i8
  %true_4 = hw.constant true
  %12 = comb.xor %a, %true_4 : i1
  %13 = comb.and %7, %12 : i1
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %c0_i8_6 = hw.constant 0 : i8
  %14 = seq.initial() {
    %c0_i8_15 = hw.constant 0 : i8
    seq.yield %c0_i8_15 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %15, %clk, %13 reset %rst, %c0_i8_6 initial %14 : i8  
  %15 = comb.add %reg_0, %c1_i8 : i8
  %16 = comb.and %8, %b : i1
  %true_7 = hw.constant true
  %17 = comb.xor %b, %true_7 : i1
  %18 = comb.and %8, %17 : i1
  %19 = comb.and %13, %b : i1
  %20 = comb.mux %3, %11, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %21 = comb.add %1, %c1_i64 : i64
  %c0_i64_8 = hw.constant 0 : i64
  %22 = comb.and %7, %16 : i1
  %23 = comb.icmp eq %21, %count : i64
  %24 = comb.and %7, %23 : i1
  %25 = comb.or %24, %22 : i1
  %26 = comb.mux %22, %count, %21 : i64
  %27 = comb.mux %7, %26, %c0_i64_8 : i64
  %false_9 = hw.constant false
  %false_10 = hw.constant false
  %28 = seq.initial() {
    %false_15 = hw.constant false
    seq.yield %false_15 : i1
  } : () -> !seq.immutable<i1>
  %29 = seq.compreg %25, %clk reset %rst, %false_10 initial %28 : i1  
  %true_11 = hw.constant true
  %30 = comb.xor %25, %true_11 : i1
  %true_12 = hw.constant true
  %31 = comb.mux %3, %30, %true_12 : i1
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %32 = seq.initial() {
    %c0_i8_15 = hw.constant 0 : i8
    seq.yield %c0_i8_15 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %5, %clk, %29 reset %rst, %c0_i8_14 initial %32 : i8  
  hw.output %reg_1 : i8
}
hw.module @NestedIfBreak(in %count : i64, in %a : i1, in %b : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_14 = hw.constant 0 : i64
    seq.yield %c0_i64_14 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %25, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_14 = hw.constant false
    seq.yield %false_14 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %29, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %18, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %true = hw.constant true
  %10 = comb.xor %a, %true : i1
  %11 = comb.and %7, %a : i1
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %12 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %13, %clk, %11 reset %rst, %c0_i8_5 initial %12 : i8  
  %13 = comb.add %reg_0, %c1_i8 : i8
  %14 = comb.and %a, %b : i1
  %true_6 = hw.constant true
  %15 = comb.xor %b, %true_6 : i1
  %16 = comb.and %a, %15 : i1
  %17 = comb.and %11, %b : i1
  %18 = comb.mux %3, %9, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %19 = comb.add %1, %c1_i64 : i64
  %c0_i64_7 = hw.constant 0 : i64
  %20 = comb.and %7, %14 : i1
  %21 = comb.icmp eq %19, %count : i64
  %22 = comb.and %7, %21 : i1
  %23 = comb.or %22, %20 : i1
  %24 = comb.mux %20, %count, %19 : i64
  %25 = comb.mux %7, %24, %c0_i64_7 : i64
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %26 = seq.initial() {
    %false_14 = hw.constant false
    seq.yield %false_14 : i1
  } : () -> !seq.immutable<i1>
  %27 = seq.compreg %23, %clk reset %rst, %false_9 initial %26 : i1  
  %true_10 = hw.constant true
  %28 = comb.xor %23, %true_10 : i1
  %true_11 = hw.constant true
  %29 = comb.mux %3, %28, %true_11 : i1
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %30 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %5, %clk, %27 reset %rst, %c0_i8_13 initial %30 : i8  
  hw.output %reg_1 : i8
}
hw.module @NestedLoopBreak(in %n : i64, in %m : i64, in %a : i1, in %b : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_18 = hw.constant 0 : i64
    seq.yield %c0_i64_18 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %35, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_18 = hw.constant false
    seq.yield %false_18 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %39, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_18 = hw.constant 0 : i8
    seq.yield %c0_i8_18 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %30, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %n : i64
  %7 = comb.and %3, %6 : i1
  %c0_i64_4 = hw.constant 0 : i64
  %c0_i64_5 = hw.constant 0 : i64
  %8 = seq.initial() {
    %c0_i64_18 = hw.constant 0 : i64
    seq.yield %c0_i64_18 : i64
  } : () -> !seq.immutable<i64>
  %9 = seq.compreg %29, %clk reset %rst, %c0_i64_5 initial %8 : i64  
  %10 = comb.icmp ult %9, %m : i64
  %11 = comb.and %7, %10 : i1
  %12 = comb.add %5, %wd : i8
  %13 = comb.mux %11, %12, %5 : i8
  %true = hw.constant true
  %14 = comb.xor %a, %true : i1
  %15 = comb.and %11, %a : i1
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_6 = hw.constant 0 : i8
  %c0_i8_7 = hw.constant 0 : i8
  %16 = seq.initial() {
    %c0_i8_18 = hw.constant 0 : i8
    seq.yield %c0_i8_18 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %17, %clk, %15 reset %rst, %c0_i8_7 initial %16 : i8  
  %17 = comb.add %reg_0, %c1_i8 : i8
  %18 = comb.and %a, %b : i1
  %true_8 = hw.constant true
  %19 = comb.xor %b, %true_8 : i1
  %20 = comb.and %a, %19 : i1
  %21 = comb.and %15, %b : i1
  %22 = comb.and %11, %18 : i1
  %c1_i64 = hw.constant 1 : i64
  %23 = comb.add %9, %c1_i64 : i64
  %c0_i64_9 = hw.constant 0 : i64
  %24 = comb.icmp eq %23, %m : i64
  %25 = comb.and %11, %24 : i1
  %26 = comb.or %25, %22 : i1
  %27 = comb.mux %26, %c0_i64_9, %23 : i64
  %28 = comb.mux %22, %m, %27 : i64
  %29 = comb.mux %11, %28, %c0_i64_9 : i64
  %30 = comb.mux %3, %13, %c0_i8 : i8
  %c1_i64_10 = hw.constant 1 : i64
  %31 = comb.add %1, %c1_i64_10 : i64
  %c0_i64_11 = hw.constant 0 : i64
  %32 = comb.icmp eq %31, %n : i64
  %33 = comb.and %26, %32 : i1
  %34 = comb.mux %33, %c0_i64_11, %31 : i64
  %35 = comb.mux %26, %34, %1 : i64
  %false_12 = hw.constant false
  %false_13 = hw.constant false
  %36 = seq.initial() {
    %false_18 = hw.constant false
    seq.yield %false_18 : i1
  } : () -> !seq.immutable<i1>
  %37 = seq.compreg %33, %clk reset %rst, %false_13 initial %36 : i1  
  %true_14 = hw.constant true
  %38 = comb.xor %33, %true_14 : i1
  %true_15 = hw.constant true
  %39 = comb.mux %3, %38, %true_15 : i1
  %c0_i8_16 = hw.constant 0 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %40 = seq.initial() {
    %c0_i8_18 = hw.constant 0 : i8
    seq.yield %c0_i8_18 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %5, %clk, %37 reset %rst, %c0_i8_17 initial %40 : i8  
  hw.output %reg_1 : i8
}
