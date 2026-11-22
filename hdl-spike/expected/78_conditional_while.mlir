hw.module @LogicWhileConditional(in %count : i64, in %a : i1, in %b : i1, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_19 = hw.constant 0 : i64
    seq.yield %c0_i64_19 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %44, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_19 = hw.constant false
    seq.yield %false_19 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %48, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %36, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %37, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %true = hw.constant true
  %10 = comb.xor %a, %true : i1
  %11 = comb.and %9, %a : i1
  %12 = comb.or %7, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %13 = comb.xor %5, %c-1_i8 : i8
  %14 = comb.or %7, %13 : i8
  %c-1_i8_5 = hw.constant -1 : i8
  %15 = comb.xor %wd, %c-1_i8_5 : i8
  %16 = comb.or %wd_xz, %15 : i8
  %17 = comb.and %12, %14 : i8
  %18 = comb.and %17, %16 : i8
  %19 = comb.or %5, %wd : i8
  %20 = comb.mux %11, %19, %5 : i8
  %21 = comb.mux %11, %18, %7 : i8
  %22 = comb.and %a, %b : i1
  %true_6 = hw.constant true
  %23 = comb.xor %b, %true_6 : i1
  %24 = comb.and %a, %23 : i1
  %25 = comb.and %11, %b : i1
  %true_7 = hw.constant true
  %26 = comb.xor %a, %true_7 : i1
  %27 = comb.and %9, %26 : i1
  %28 = comb.or %21, %wd_xz : i8
  %29 = comb.or %21, %20 : i8
  %30 = comb.or %wd_xz, %wd : i8
  %31 = comb.and %28, %29 : i8
  %32 = comb.and %31, %30 : i8
  %33 = comb.and %20, %wd : i8
  %34 = comb.mux %27, %33, %20 : i8
  %35 = comb.mux %27, %32, %21 : i8
  %36 = comb.mux %3, %34, %wd : i8
  %37 = comb.mux %3, %35, %wd_xz : i8
  %c1_i64 = hw.constant 1 : i64
  %38 = comb.add %1, %c1_i64 : i64
  %c0_i64_8 = hw.constant 0 : i64
  %39 = comb.and %9, %22 : i1
  %40 = comb.icmp eq %38, %count : i64
  %41 = comb.and %9, %40 : i1
  %42 = comb.or %41, %39 : i1
  %43 = comb.mux %39, %count, %38 : i64
  %44 = comb.mux %9, %43, %c0_i64_8 : i64
  %false_9 = hw.constant false
  %false_10 = hw.constant false
  %45 = seq.initial() {
    %false_19 = hw.constant false
    seq.yield %false_19 : i1
  } : () -> !seq.immutable<i1>
  %46 = seq.compreg %42, %clk reset %rst, %false_10 initial %45 : i1  
  %true_11 = hw.constant true
  %47 = comb.xor %42, %true_11 : i1
  %true_12 = hw.constant true
  %48 = comb.mux %3, %47, %true_12 : i1
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %49 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %50 = seq.compreg %53, %clk reset %rst, %c0_i8_14 initial %49 : i8  
  %c0_i8_15 = hw.constant 0 : i8
  %c0_i8_16 = hw.constant 0 : i8
  %51 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %52 = seq.compreg %54, %clk reset %rst, %c0_i8_16 initial %51 : i8  
  %53 = comb.mux %46, %5, %50 : i8
  %54 = comb.mux %46, %7, %52 : i8
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %c0_i8_18 = hw.constant 0 : i8
  %55 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %56, %clk, %46 reset %rst, %c0_i8_18 initial %55 : i8  
  %56 = comb.add %reg_1, %c1_i8 : i8
  hw.output %50, %52 : i8, i8
}
hw.module @WhileConditionalCarry(in %count : i64, in %a : i1, in %b : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_16 = hw.constant 0 : i64
    seq.yield %c0_i64_16 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %29, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %33, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %22, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %true = hw.constant true
  %10 = comb.xor %a, %true : i1
  %11 = comb.and %7, %a : i1
  %c1_i8 = hw.constant 1 : i8
  %12 = comb.add %9, %c1_i8 : i8
  %13 = comb.mux %11, %12, %9 : i8
  %14 = comb.and %a, %b : i1
  %true_4 = hw.constant true
  %15 = comb.xor %b, %true_4 : i1
  %16 = comb.and %a, %15 : i1
  %17 = comb.and %11, %b : i1
  %true_5 = hw.constant true
  %18 = comb.xor %a, %true_5 : i1
  %19 = comb.and %7, %18 : i1
  %c2_i8 = hw.constant 2 : i8
  %20 = comb.add %13, %c2_i8 : i8
  %21 = comb.mux %19, %20, %13 : i8
  %22 = comb.mux %3, %21, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %23 = comb.add %1, %c1_i64 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %24 = comb.and %7, %14 : i1
  %25 = comb.icmp eq %23, %count : i64
  %26 = comb.and %7, %25 : i1
  %27 = comb.or %26, %24 : i1
  %28 = comb.mux %24, %count, %23 : i64
  %29 = comb.mux %7, %28, %c0_i64_6 : i64
  %false_7 = hw.constant false
  %false_8 = hw.constant false
  %30 = seq.initial() {
    %false_16 = hw.constant false
    seq.yield %false_16 : i1
  } : () -> !seq.immutable<i1>
  %31 = seq.compreg %27, %clk reset %rst, %false_8 initial %30 : i1  
  %true_9 = hw.constant true
  %32 = comb.xor %27, %true_9 : i1
  %true_10 = hw.constant true
  %33 = comb.mux %3, %32, %true_10 : i1
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %34 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %5, %clk, %31 reset %rst, %c0_i8_12 initial %34 : i8  
  %c1_i8_13 = hw.constant 1 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %35 = seq.initial() {
    %c0_i8_16 = hw.constant 0 : i8
    seq.yield %c0_i8_16 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %36, %clk, %31 reset %rst, %c0_i8_15 initial %35 : i8  
  %36 = comb.add %reg_1, %c1_i8_13 : i8
  hw.output %reg_0 : i8
}
