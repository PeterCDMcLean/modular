hw.module @SequencedAccum(in %n : i64, in %m : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_29 = hw.constant 0 : i64
    seq.yield %c0_i64_29 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %22, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %n : i64
  %true = hw.constant true
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %9 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %12 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %15 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %18 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i64_5 = hw.constant 0 : i64
  %7 = comb.icmp eq %1, %c0_i64_5 : i64
  %8 = comb.and %true, %7 : i1
  %9 = comb.and %2, %8 : i1
  %c1_i64 = hw.constant 1 : i64
  %10 = comb.icmp eq %1, %c1_i64 : i64
  %11 = comb.and %true, %10 : i1
  %12 = comb.and %2, %11 : i1
  %c2_i64 = hw.constant 2 : i64
  %13 = comb.icmp eq %1, %c2_i64 : i64
  %14 = comb.and %true, %13 : i1
  %15 = comb.and %2, %14 : i1
  %c3_i64 = hw.constant 3 : i64
  %16 = comb.icmp eq %1, %c3_i64 : i64
  %17 = comb.and %true, %16 : i1
  %18 = comb.and %2, %17 : i1
  %c1_i64_6 = hw.constant 1 : i64
  %19 = comb.add %1, %c1_i64_6 : i64
  %c0_i64_7 = hw.constant 0 : i64
  %20 = comb.icmp eq %19, %n : i64
  %21 = comb.and %2, %20 : i1
  %22 = comb.mux %2, %19, %1 : i64
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %23 = seq.initial() {
    %false_29 = hw.constant false
    seq.yield %false_29 : i1
  } : () -> !seq.immutable<i1>
  %24 = seq.compreg %21, %clk reset %rst, %false_9 initial %23 : i1  
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i64_11 = hw.constant 0 : i64
  %c0_i64_12 = hw.constant 0 : i64
  %25 = seq.initial() {
    %c0_i64_29 = hw.constant 0 : i64
    seq.yield %c0_i64_29 : i64
  } : () -> !seq.immutable<i64>
  %26 = seq.compreg %42, %clk reset %rst, %c0_i64_12 initial %25 : i64  
  %false_13 = hw.constant false
  %false_14 = hw.constant false
  %27 = seq.initial() {
    %false_29 = hw.constant false
    seq.yield %false_29 : i1
  } : () -> !seq.immutable<i1>
  %28 = seq.compreg %44, %clk reset %rst, %false_14 initial %27 : i1  
  %false_15 = hw.constant false
  %false_16 = hw.constant false
  %29 = seq.initial() {
    %false_29 = hw.constant false
    seq.yield %false_29 : i1
  } : () -> !seq.immutable<i1>
  %30 = seq.compreg %49, %clk reset %rst, %false_16 initial %29 : i1  
  %c0_i8_17 = hw.constant 0 : i8
  %c0_i8_18 = hw.constant 0 : i8
  %31 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %32 = seq.compreg %38, %clk reset %rst, %c0_i8_18 initial %31 : i8  
  %33 = comb.icmp ult %26, %m : i64
  %34 = comb.and %30, %33 : i1
  %35 = comb.and %28, %34 : i1
  %36 = comb.add %32, %wd : i8
  %37 = comb.mux %35, %36, %32 : i8
  %38 = comb.mux %30, %37, %c0_i8_10 : i8
  %c1_i64_19 = hw.constant 1 : i64
  %39 = comb.add %26, %c1_i64_19 : i64
  %c0_i64_20 = hw.constant 0 : i64
  %40 = comb.icmp eq %39, %m : i64
  %41 = comb.and %35, %40 : i1
  %42 = comb.mux %35, %39, %c0_i64_20 : i64
  %false_21 = hw.constant false
  %43 = comb.mux %41, %false_21, %28 : i1
  %44 = comb.mux %24, %true, %43 : i1
  %false_22 = hw.constant false
  %false_23 = hw.constant false
  %45 = seq.initial() {
    %false_29 = hw.constant false
    seq.yield %false_29 : i1
  } : () -> !seq.immutable<i1>
  %46 = seq.compreg %41, %clk reset %rst, %false_23 initial %45 : i1  
  %true_24 = hw.constant true
  %47 = comb.xor %41, %true_24 : i1
  %48 = comb.mux %30, %47, %true : i1
  %49 = comb.mux %28, %48, %false_21 : i1
  %c0_i8_25 = hw.constant 0 : i8
  %c0_i8_26 = hw.constant 0 : i8
  %50 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %32, %clk, %46 reset %rst, %c0_i8_26 initial %50 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_27 = hw.constant 0 : i8
  %c0_i8_28 = hw.constant 0 : i8
  %51 = seq.initial() {
    %c0_i8_29 = hw.constant 0 : i8
    seq.yield %c0_i8_29 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %52, %clk, %46 reset %rst, %c0_i8_28 initial %51 : i8  
  %52 = comb.add %reg_2, %c1_i8 : i8
  hw.output %reg_1 : i8
}
hw.module @SequencedLogicAccum(in %n : i64, in %m : i64, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_28 = hw.constant 0 : i64
    seq.yield %c0_i64_28 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %8, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %n : i64
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %4, %clk, %2 reset %rst, %c0_i8_1 initial %3 : i8  
  %4 = comb.add %reg_0, %c1_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %5 = comb.add %1, %c1_i64 : i64
  %c0_i64_2 = hw.constant 0 : i64
  %6 = comb.icmp eq %5, %n : i64
  %7 = comb.and %2, %6 : i1
  %8 = comb.mux %2, %5, %1 : i64
  %false = hw.constant false
  %false_3 = hw.constant false
  %9 = seq.initial() {
    %false_28 = hw.constant false
    seq.yield %false_28 : i1
  } : () -> !seq.immutable<i1>
  %10 = seq.compreg %7, %clk reset %rst, %false_3 initial %9 : i1  
  %c0_i64_4 = hw.constant 0 : i64
  %c0_i64_5 = hw.constant 0 : i64
  %11 = seq.initial() {
    %c0_i64_28 = hw.constant 0 : i64
    seq.yield %c0_i64_28 : i64
  } : () -> !seq.immutable<i64>
  %12 = seq.compreg %39, %clk reset %rst, %c0_i64_5 initial %11 : i64  
  %false_6 = hw.constant false
  %false_7 = hw.constant false
  %13 = seq.initial() {
    %false_28 = hw.constant false
    seq.yield %false_28 : i1
  } : () -> !seq.immutable<i1>
  %14 = seq.compreg %41, %clk reset %rst, %false_7 initial %13 : i1  
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %15 = seq.initial() {
    %false_28 = hw.constant false
    seq.yield %false_28 : i1
  } : () -> !seq.immutable<i1>
  %16 = seq.compreg %46, %clk reset %rst, %false_9 initial %15 : i1  
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %17 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %18 = seq.compreg %34, %clk reset %rst, %c0_i8_11 initial %17 : i8  
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %19 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %20 = seq.compreg %35, %clk reset %rst, %c0_i8_13 initial %19 : i8  
  %21 = comb.icmp ult %12, %m : i64
  %22 = comb.and %16, %21 : i1
  %23 = comb.and %14, %22 : i1
  %24 = comb.or %20, %wd_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %25 = comb.xor %18, %c-1_i8 : i8
  %26 = comb.or %20, %25 : i8
  %c-1_i8_14 = hw.constant -1 : i8
  %27 = comb.xor %wd, %c-1_i8_14 : i8
  %28 = comb.or %wd_xz, %27 : i8
  %29 = comb.and %24, %26 : i8
  %30 = comb.and %29, %28 : i8
  %31 = comb.or %18, %wd : i8
  %32 = comb.mux %23, %31, %18 : i8
  %33 = comb.mux %23, %30, %20 : i8
  %34 = comb.mux %16, %32, %wd : i8
  %35 = comb.mux %16, %33, %wd_xz : i8
  %c1_i64_15 = hw.constant 1 : i64
  %36 = comb.add %12, %c1_i64_15 : i64
  %c0_i64_16 = hw.constant 0 : i64
  %37 = comb.icmp eq %36, %m : i64
  %38 = comb.and %23, %37 : i1
  %39 = comb.mux %23, %36, %c0_i64_16 : i64
  %true = hw.constant true
  %false_17 = hw.constant false
  %40 = comb.mux %38, %false_17, %14 : i1
  %41 = comb.mux %10, %true, %40 : i1
  %false_18 = hw.constant false
  %false_19 = hw.constant false
  %42 = seq.initial() {
    %false_28 = hw.constant false
    seq.yield %false_28 : i1
  } : () -> !seq.immutable<i1>
  %43 = seq.compreg %38, %clk reset %rst, %false_19 initial %42 : i1  
  %true_20 = hw.constant true
  %44 = comb.xor %38, %true_20 : i1
  %45 = comb.mux %16, %44, %true : i1
  %46 = comb.mux %14, %45, %false_17 : i1
  %c0_i8_21 = hw.constant 0 : i8
  %c0_i8_22 = hw.constant 0 : i8
  %47 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %48 = seq.compreg %51, %clk reset %rst, %c0_i8_22 initial %47 : i8  
  %c0_i8_23 = hw.constant 0 : i8
  %c0_i8_24 = hw.constant 0 : i8
  %49 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %50 = seq.compreg %52, %clk reset %rst, %c0_i8_24 initial %49 : i8  
  %51 = comb.mux %43, %18, %48 : i8
  %52 = comb.mux %43, %20, %50 : i8
  %c1_i8_25 = hw.constant 1 : i8
  %c0_i8_26 = hw.constant 0 : i8
  %c0_i8_27 = hw.constant 0 : i8
  %53 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %54, %clk, %43 reset %rst, %c0_i8_27 initial %53 : i8  
  %54 = comb.add %reg_2, %c1_i8_25 : i8
  hw.output %48, %50 : i8, i8
}
