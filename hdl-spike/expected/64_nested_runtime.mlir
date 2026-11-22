hw.module @NestedRuntimeFill(in %outer : i64, in %inner : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_23 = hw.constant 0 : i64
    seq.yield %c0_i64_23 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %51, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %outer : i64
  %c0_i64_1 = hw.constant 0 : i64
  %c0_i64_2 = hw.constant 0 : i64
  %3 = seq.initial() {
    %c0_i64_23 = hw.constant 0 : i64
    seq.yield %c0_i64_23 : i64
  } : () -> !seq.immutable<i64>
  %4 = seq.compreg %46, %clk reset %rst, %c0_i64_2 initial %3 : i64  
  %5 = comb.icmp ult %4, %inner : i64
  %6 = comb.and %2, %5 : i1
  %c2_i64 = hw.constant 2 : i64
  %7 = comb.mul %1, %c2_i64 : i64
  %8 = comb.add %7, %4 : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_3 = hw.constant 0 : i8
  %9 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %19 reset %rst, %c0_i8_3 initial %9 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %22 reset %rst, %c0_i8_4 initial %10 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %11 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %25 reset %rst, %c0_i8_5 initial %11 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %12 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %28 reset %rst, %c0_i8_6 initial %12 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %13 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_4 = seq.compreg.ce sym @mem_0_4 %wd, %clk, %31 reset %rst, %c0_i8_7 initial %13 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %14 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_5 = seq.compreg.ce sym @mem_0_5 %wd, %clk, %34 reset %rst, %c0_i8_8 initial %14 : i8  
  %c0_i8_9 = hw.constant 0 : i8
  %15 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_6 = seq.compreg.ce sym @mem_0_6 %wd, %clk, %37 reset %rst, %c0_i8_9 initial %15 : i8  
  %c0_i8_10 = hw.constant 0 : i8
  %16 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_7 = seq.compreg.ce sym @mem_0_7 %wd, %clk, %40 reset %rst, %c0_i8_10 initial %16 : i8  
  %c0_i64_11 = hw.constant 0 : i64
  %17 = comb.icmp eq %8, %c0_i64_11 : i64
  %18 = comb.and %en, %17 : i1
  %19 = comb.and %6, %18 : i1
  %c1_i64 = hw.constant 1 : i64
  %20 = comb.icmp eq %8, %c1_i64 : i64
  %21 = comb.and %en, %20 : i1
  %22 = comb.and %6, %21 : i1
  %c2_i64_12 = hw.constant 2 : i64
  %23 = comb.icmp eq %8, %c2_i64_12 : i64
  %24 = comb.and %en, %23 : i1
  %25 = comb.and %6, %24 : i1
  %c3_i64 = hw.constant 3 : i64
  %26 = comb.icmp eq %8, %c3_i64 : i64
  %27 = comb.and %en, %26 : i1
  %28 = comb.and %6, %27 : i1
  %c4_i64 = hw.constant 4 : i64
  %29 = comb.icmp eq %8, %c4_i64 : i64
  %30 = comb.and %en, %29 : i1
  %31 = comb.and %6, %30 : i1
  %c5_i64 = hw.constant 5 : i64
  %32 = comb.icmp eq %8, %c5_i64 : i64
  %33 = comb.and %en, %32 : i1
  %34 = comb.and %6, %33 : i1
  %c6_i64 = hw.constant 6 : i64
  %35 = comb.icmp eq %8, %c6_i64 : i64
  %36 = comb.and %en, %35 : i1
  %37 = comb.and %6, %36 : i1
  %c7_i64 = hw.constant 7 : i64
  %38 = comb.icmp eq %8, %c7_i64 : i64
  %39 = comb.and %en, %38 : i1
  %40 = comb.and %6, %39 : i1
  %c0_i8_13 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %41 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %wd, %clk, %6 reset %rst, %c0_i8_14 initial %41 : i8  
  %c1_i64_15 = hw.constant 1 : i64
  %42 = comb.add %4, %c1_i64_15 : i64
  %c0_i64_16 = hw.constant 0 : i64
  %43 = comb.icmp eq %42, %inner : i64
  %44 = comb.and %6, %43 : i1
  %45 = comb.mux %44, %c0_i64_16, %42 : i64
  %46 = comb.mux %6, %45, %c0_i64_16 : i64
  %c1_i64_17 = hw.constant 1 : i64
  %47 = comb.add %1, %c1_i64_17 : i64
  %c0_i64_18 = hw.constant 0 : i64
  %48 = comb.icmp eq %47, %outer : i64
  %49 = comb.and %44, %48 : i1
  %50 = comb.mux %49, %c0_i64_18, %47 : i64
  %51 = comb.mux %44, %50, %1 : i64
  %false_19 = hw.constant false
  %false_20 = hw.constant false
  %52 = seq.initial() {
    %false_23 = hw.constant false
    seq.yield %false_23 : i1
  } : () -> !seq.immutable<i1>
  %53 = seq.compreg %49, %clk reset %rst, %false_20 initial %52 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_21 = hw.constant 0 : i8
  %c0_i8_22 = hw.constant 0 : i8
  %54 = seq.initial() {
    %c0_i8_23 = hw.constant 0 : i8
    seq.yield %c0_i8_23 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %55, %clk, %53 reset %rst, %c0_i8_22 initial %54 : i8  
  %55 = comb.add %reg_2, %c1_i8 : i8
  hw.output %reg_1 : i8
}
