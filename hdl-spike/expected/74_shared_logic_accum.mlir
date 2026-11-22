hw.module @SharedLogicAccum(in %n : i64, in %m : i64, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %67, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %66, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %68, %clk reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %69, %clk reset %rst, %c0_i8_4 initial %6 : i8  
  %8 = comb.icmp ult %1, %n : i64
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
  %20 = comb.mux %3, %18, %wd : i8
  %21 = comb.mux %3, %19, %wd_xz : i8
  %c1_i64 = hw.constant 1 : i64
  %22 = comb.add %1, %c1_i64 : i64
  %c0_i64_6 = hw.constant 0 : i64
  %23 = comb.icmp eq %22, %n : i64
  %24 = comb.and %9, %23 : i1
  %25 = comb.mux %9, %22, %1 : i64
  %false_7 = hw.constant false
  %false_8 = hw.constant false
  %26 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %27 = seq.compreg %24, %clk reset %rst, %false_8 initial %26 : i1  
  %true = hw.constant true
  %28 = comb.xor %24, %true : i1
  %true_9 = hw.constant true
  %29 = comb.mux %3, %28, %true_9 : i1
  %c0_i64_10 = hw.constant 0 : i64
  %c0_i64_11 = hw.constant 0 : i64
  %30 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %31 = seq.compreg %58, %clk reset %rst, %c0_i64_11 initial %30 : i64  
  %false_12 = hw.constant false
  %false_13 = hw.constant false
  %32 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %33 = seq.compreg %60, %clk reset %rst, %false_13 initial %32 : i1  
  %false_14 = hw.constant false
  %false_15 = hw.constant false
  %34 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %35 = seq.compreg %65, %clk reset %rst, %false_15 initial %34 : i1  
  %c0_i8_16 = hw.constant 0 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %36 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %37 = seq.compreg %53, %clk reset %rst, %c0_i8_17 initial %36 : i8  
  %c0_i8_18 = hw.constant 0 : i8
  %c0_i8_19 = hw.constant 0 : i8
  %38 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %39 = seq.compreg %54, %clk reset %rst, %c0_i8_19 initial %38 : i8  
  %40 = comb.icmp ult %31, %m : i64
  %41 = comb.and %35, %40 : i1
  %42 = comb.and %33, %41 : i1
  %43 = comb.or %39, %wd_xz : i8
  %c-1_i8_20 = hw.constant -1 : i8
  %44 = comb.xor %37, %c-1_i8_20 : i8
  %45 = comb.or %39, %44 : i8
  %c-1_i8_21 = hw.constant -1 : i8
  %46 = comb.xor %wd, %c-1_i8_21 : i8
  %47 = comb.or %wd_xz, %46 : i8
  %48 = comb.and %43, %45 : i8
  %49 = comb.and %48, %47 : i8
  %50 = comb.or %37, %wd : i8
  %51 = comb.mux %42, %50, %37 : i8
  %52 = comb.mux %42, %49, %39 : i8
  %53 = comb.mux %35, %51, %5 : i8
  %54 = comb.mux %35, %52, %7 : i8
  %c1_i64_22 = hw.constant 1 : i64
  %55 = comb.add %31, %c1_i64_22 : i64
  %c0_i64_23 = hw.constant 0 : i64
  %56 = comb.icmp eq %55, %m : i64
  %57 = comb.and %42, %56 : i1
  %58 = comb.mux %42, %55, %c0_i64_23 : i64
  %false_24 = hw.constant false
  %59 = comb.mux %57, %false_24, %33 : i1
  %60 = comb.mux %27, %true_9, %59 : i1
  %false_25 = hw.constant false
  %false_26 = hw.constant false
  %61 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %62 = seq.compreg %57, %clk reset %rst, %false_26 initial %61 : i1  
  %true_27 = hw.constant true
  %63 = comb.xor %57, %true_27 : i1
  %64 = comb.mux %35, %63, %true_9 : i1
  %65 = comb.mux %33, %64, %false_24 : i1
  %66 = comb.mux %62, %false_24, %true_9 : i1
  %c0_i64_28 = hw.constant 0 : i64
  %67 = comb.mux %62, %c0_i64_28, %25 : i64
  %68 = comb.mux %62, %wd, %20 : i8
  %69 = comb.mux %62, %wd_xz, %21 : i8
  %c0_i8_29 = hw.constant 0 : i8
  %c0_i8_30 = hw.constant 0 : i8
  %70 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %71 = seq.compreg %74, %clk reset %rst, %c0_i8_30 initial %70 : i8  
  %c0_i8_31 = hw.constant 0 : i8
  %c0_i8_32 = hw.constant 0 : i8
  %72 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %73 = seq.compreg %75, %clk reset %rst, %c0_i8_32 initial %72 : i8  
  %74 = comb.mux %62, %37, %71 : i8
  %75 = comb.mux %62, %39, %73 : i8
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_33 = hw.constant 0 : i8
  %c0_i8_34 = hw.constant 0 : i8
  %76 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %77, %clk, %62 reset %rst, %c0_i8_34 initial %76 : i8  
  %77 = comb.add %reg_1, %c1_i8 : i8
  hw.output %71, %73 : i8, i8
}
