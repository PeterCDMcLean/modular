hw.module @LogicLoopInBranch(in %count : i64, in %go : i1, in %stop : i1, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %true = hw.constant true
  %0 = comb.xor %go, %true : i1
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %1 = seq.initial() {
    %c0_i64_21 = hw.constant 0 : i64
    seq.yield %c0_i64_21 : i64
  } : () -> !seq.immutable<i64>
  %2 = seq.compreg %47, %clk reset %rst, %c0_i64_0 initial %1 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %3 = seq.initial() {
    %false_21 = hw.constant false
    seq.yield %false_21 : i1
  } : () -> !seq.immutable<i1>
  %4 = seq.compreg %52, %clk reset %rst, %false_1 initial %3 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_21 = hw.constant 0 : i8
    seq.yield %c0_i8_21 : i8
  } : () -> !seq.immutable<i8>
  %6 = seq.compreg %38, %clk reset %rst, %c0_i8_2 initial %5 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %7 = seq.initial() {
    %c0_i8_21 = hw.constant 0 : i8
    seq.yield %c0_i8_21 : i8
  } : () -> !seq.immutable<i8>
  %8 = seq.compreg %39, %clk reset %rst, %c0_i8_4 initial %7 : i8  
  %9 = comb.icmp ult %2, %count : i64
  %10 = comb.and %4, %9 : i1
  %11 = comb.and %go, %10 : i1
  %12 = comb.and %go, %10 : i1
  %13 = comb.and %go, %10 : i1
  %14 = comb.and %go, %10 : i1
  %15 = comb.and %go, %10 : i1
  %16 = comb.and %go, %10 : i1
  %17 = comb.and %go, %10 : i1
  %18 = comb.or %8, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %19 = comb.xor %6, %c-1_i8 : i8
  %20 = comb.or %8, %19 : i8
  %c-1_i8_5 = hw.constant -1 : i8
  %21 = comb.xor %wd, %c-1_i8_5 : i8
  %22 = comb.or %wd_xz, %21 : i8
  %23 = comb.and %18, %20 : i8
  %24 = comb.and %23, %22 : i8
  %25 = comb.or %6, %wd : i8
  %26 = comb.and %go, %10 : i1
  %27 = comb.and %go, %10 : i1
  %28 = comb.and %go, %10 : i1
  %29 = comb.and %go, %10 : i1
  %30 = comb.mux %29, %25, %6 : i8
  %31 = comb.mux %29, %24, %8 : i8
  %32 = comb.and %go, %10 : i1
  %33 = comb.and %go, %10 : i1
  %34 = comb.and %go, %10 : i1
  %true_6 = hw.constant true
  %35 = comb.xor %stop, %true_6 : i1
  %36 = comb.and %34, %stop : i1
  %37 = comb.and %go, %10 : i1
  %38 = comb.mux %4, %30, %wd : i8
  %39 = comb.mux %4, %31, %wd_xz : i8
  %c1_i64 = hw.constant 1 : i64
  %40 = comb.add %2, %c1_i64 : i64
  %c0_i64_7 = hw.constant 0 : i64
  %41 = comb.and %go, %10 : i1
  %42 = comb.and %41, %stop : i1
  %43 = comb.icmp eq %40, %count : i64
  %44 = comb.and %41, %43 : i1
  %45 = comb.or %44, %42 : i1
  %46 = comb.mux %42, %count, %40 : i64
  %47 = comb.mux %41, %46, %c0_i64_7 : i64
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %48 = seq.initial() {
    %false_21 = hw.constant false
    seq.yield %false_21 : i1
  } : () -> !seq.immutable<i1>
  %49 = seq.compreg %45, %clk reset %rst, %false_9 initial %48 : i1  
  %true_10 = hw.constant true
  %50 = comb.xor %45, %true_10 : i1
  %true_11 = hw.constant true
  %51 = comb.mux %4, %50, %true_11 : i1
  %false_12 = hw.constant false
  %52 = comb.mux %go, %51, %false_12 : i1
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %53 = seq.initial() {
    %c0_i8_21 = hw.constant 0 : i8
    seq.yield %c0_i8_21 : i8
  } : () -> !seq.immutable<i8>
  %54 = seq.compreg %57, %clk reset %rst, %c0_i8_14 initial %53 : i8  
  %c0_i8_15 = hw.constant 0 : i8
  %c0_i8_16 = hw.constant 0 : i8
  %55 = seq.initial() {
    %c0_i8_21 = hw.constant 0 : i8
    seq.yield %c0_i8_21 : i8
  } : () -> !seq.immutable<i8>
  %56 = seq.compreg %58, %clk reset %rst, %c0_i8_16 initial %55 : i8  
  %57 = comb.mux %49, %6, %54 : i8
  %58 = comb.mux %49, %8, %56 : i8
  %59 = comb.or %wd_xz, %wd_xz : i8
  %60 = comb.or %wd_xz, %wd : i8
  %61 = comb.or %wd_xz, %wd : i8
  %62 = comb.and %59, %60 : i8
  %63 = comb.and %62, %61 : i8
  %64 = comb.and %wd, %wd : i8
  %65 = comb.mux %0, %64, %wd : i8
  %66 = comb.mux %0, %63, %wd_xz : i8
  %67 = comb.mux %go, %6, %65 : i8
  %68 = comb.mux %go, %8, %66 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %c0_i8_18 = hw.constant 0 : i8
  %69 = seq.initial() {
    %c0_i8_21 = hw.constant 0 : i8
    seq.yield %c0_i8_21 : i8
  } : () -> !seq.immutable<i8>
  %70 = seq.compreg %67, %clk reset %rst, %c0_i8_18 initial %69 : i8  
  %c0_i8_19 = hw.constant 0 : i8
  %c0_i8_20 = hw.constant 0 : i8
  %71 = seq.initial() {
    %c0_i8_21 = hw.constant 0 : i8
    seq.yield %c0_i8_21 : i8
  } : () -> !seq.immutable<i8>
  %72 = seq.compreg %68, %clk reset %rst, %c0_i8_20 initial %71 : i8  
  hw.output %70, %72 : i8, i8
}
hw.module @LoopInBranch(in %count : i64, in %go : i1, in %stop : i1, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %true = hw.constant true
  %0 = comb.xor %go, %true : i1
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %1 = seq.initial() {
    %c0_i64_15 = hw.constant 0 : i64
    seq.yield %c0_i64_15 : i64
  } : () -> !seq.immutable<i64>
  %2 = seq.compreg %36, %clk reset %rst, %c0_i64_0 initial %1 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %3 = seq.initial() {
    %false_15 = hw.constant false
    seq.yield %false_15 : i1
  } : () -> !seq.immutable<i1>
  %4 = seq.compreg %41, %clk reset %rst, %false_1 initial %3 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_15 = hw.constant 0 : i8
    seq.yield %c0_i8_15 : i8
  } : () -> !seq.immutable<i8>
  %6 = seq.compreg %28, %clk reset %rst, %c0_i8_3 initial %5 : i8  
  %7 = comb.icmp ult %2, %count : i64
  %8 = comb.and %4, %7 : i1
  %9 = comb.and %go, %8 : i1
  %10 = comb.and %go, %8 : i1
  %11 = comb.and %go, %8 : i1
  %12 = comb.and %go, %8 : i1
  %13 = comb.and %go, %8 : i1
  %14 = comb.and %go, %8 : i1
  %15 = comb.and %go, %8 : i1
  %16 = comb.add %6, %wd : i8
  %17 = comb.and %go, %8 : i1
  %18 = comb.and %go, %8 : i1
  %19 = comb.and %go, %8 : i1
  %20 = comb.and %go, %8 : i1
  %21 = comb.mux %20, %16, %6 : i8
  %22 = comb.and %go, %8 : i1
  %23 = comb.and %go, %8 : i1
  %24 = comb.and %go, %8 : i1
  %true_4 = hw.constant true
  %25 = comb.xor %stop, %true_4 : i1
  %26 = comb.and %24, %stop : i1
  %27 = comb.and %go, %8 : i1
  %28 = comb.mux %4, %21, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %29 = comb.add %2, %c1_i64 : i64
  %c0_i64_5 = hw.constant 0 : i64
  %30 = comb.and %go, %8 : i1
  %31 = comb.and %30, %stop : i1
  %32 = comb.icmp eq %29, %count : i64
  %33 = comb.and %30, %32 : i1
  %34 = comb.or %33, %31 : i1
  %35 = comb.mux %31, %count, %29 : i64
  %36 = comb.mux %30, %35, %c0_i64_5 : i64
  %false_6 = hw.constant false
  %false_7 = hw.constant false
  %37 = seq.initial() {
    %false_15 = hw.constant false
    seq.yield %false_15 : i1
  } : () -> !seq.immutable<i1>
  %38 = seq.compreg %34, %clk reset %rst, %false_7 initial %37 : i1  
  %true_8 = hw.constant true
  %39 = comb.xor %34, %true_8 : i1
  %true_9 = hw.constant true
  %40 = comb.mux %4, %39, %true_9 : i1
  %false_10 = hw.constant false
  %41 = comb.mux %go, %40, %false_10 : i1
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %42 = seq.initial() {
    %c0_i8_15 = hw.constant 0 : i8
    seq.yield %c0_i8_15 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %6, %clk, %38 reset %rst, %c0_i8_12 initial %42 : i8  
  %43 = comb.mux %0, %wd, %c0_i8 : i8
  %44 = comb.mux %go, %6, %43 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %45 = seq.initial() {
    %c0_i8_15 = hw.constant 0 : i8
    seq.yield %c0_i8_15 : i8
  } : () -> !seq.immutable<i8>
  %46 = seq.compreg %44, %clk reset %rst, %c0_i8_14 initial %45 : i8  
  hw.output %46 : i8
}
