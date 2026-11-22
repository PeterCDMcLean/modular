hw.module @ThreeLevelFill(in %a : i64, in %b : i64, in %c : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_28 = hw.constant 0 : i64
    seq.yield %c0_i64_28 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %62, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %a : i64
  %c0_i64_1 = hw.constant 0 : i64
  %c0_i64_2 = hw.constant 0 : i64
  %3 = seq.initial() {
    %c0_i64_28 = hw.constant 0 : i64
    seq.yield %c0_i64_28 : i64
  } : () -> !seq.immutable<i64>
  %4 = seq.compreg %57, %clk reset %rst, %c0_i64_2 initial %3 : i64  
  %5 = comb.icmp ult %4, %b : i64
  %6 = comb.and %2, %5 : i1
  %c0_i64_3 = hw.constant 0 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %7 = seq.initial() {
    %c0_i64_28 = hw.constant 0 : i64
    seq.yield %c0_i64_28 : i64
  } : () -> !seq.immutable<i64>
  %8 = seq.compreg %52, %clk reset %rst, %c0_i64_4 initial %7 : i64  
  %9 = comb.icmp ult %8, %c : i64
  %10 = comb.and %6, %9 : i1
  %c4_i64 = hw.constant 4 : i64
  %11 = comb.mul %1, %c4_i64 : i64
  %c2_i64 = hw.constant 2 : i64
  %12 = comb.mul %4, %c2_i64 : i64
  %13 = comb.add %11, %12 : i64
  %14 = comb.add %13, %8 : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_5 = hw.constant 0 : i8
  %15 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %25 reset %rst, %c0_i8_5 initial %15 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %16 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %28 reset %rst, %c0_i8_6 initial %16 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %17 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %31 reset %rst, %c0_i8_7 initial %17 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %18 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %34 reset %rst, %c0_i8_8 initial %18 : i8  
  %c0_i8_9 = hw.constant 0 : i8
  %19 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_4 = seq.compreg.ce sym @mem_0_4 %wd, %clk, %37 reset %rst, %c0_i8_9 initial %19 : i8  
  %c0_i8_10 = hw.constant 0 : i8
  %20 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_5 = seq.compreg.ce sym @mem_0_5 %wd, %clk, %40 reset %rst, %c0_i8_10 initial %20 : i8  
  %c0_i8_11 = hw.constant 0 : i8
  %21 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_6 = seq.compreg.ce sym @mem_0_6 %wd, %clk, %43 reset %rst, %c0_i8_11 initial %21 : i8  
  %c0_i8_12 = hw.constant 0 : i8
  %22 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_7 = seq.compreg.ce sym @mem_0_7 %wd, %clk, %46 reset %rst, %c0_i8_12 initial %22 : i8  
  %c0_i64_13 = hw.constant 0 : i64
  %23 = comb.icmp eq %14, %c0_i64_13 : i64
  %24 = comb.and %en, %23 : i1
  %25 = comb.and %10, %24 : i1
  %c1_i64 = hw.constant 1 : i64
  %26 = comb.icmp eq %14, %c1_i64 : i64
  %27 = comb.and %en, %26 : i1
  %28 = comb.and %10, %27 : i1
  %c2_i64_14 = hw.constant 2 : i64
  %29 = comb.icmp eq %14, %c2_i64_14 : i64
  %30 = comb.and %en, %29 : i1
  %31 = comb.and %10, %30 : i1
  %c3_i64 = hw.constant 3 : i64
  %32 = comb.icmp eq %14, %c3_i64 : i64
  %33 = comb.and %en, %32 : i1
  %34 = comb.and %10, %33 : i1
  %c4_i64_15 = hw.constant 4 : i64
  %35 = comb.icmp eq %14, %c4_i64_15 : i64
  %36 = comb.and %en, %35 : i1
  %37 = comb.and %10, %36 : i1
  %c5_i64 = hw.constant 5 : i64
  %38 = comb.icmp eq %14, %c5_i64 : i64
  %39 = comb.and %en, %38 : i1
  %40 = comb.and %10, %39 : i1
  %c6_i64 = hw.constant 6 : i64
  %41 = comb.icmp eq %14, %c6_i64 : i64
  %42 = comb.and %en, %41 : i1
  %43 = comb.and %10, %42 : i1
  %c7_i64 = hw.constant 7 : i64
  %44 = comb.icmp eq %14, %c7_i64 : i64
  %45 = comb.and %en, %44 : i1
  %46 = comb.and %10, %45 : i1
  %c0_i8_16 = hw.constant 0 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %47 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %wd, %clk, %10 reset %rst, %c0_i8_17 initial %47 : i8  
  %c1_i64_18 = hw.constant 1 : i64
  %48 = comb.add %8, %c1_i64_18 : i64
  %c0_i64_19 = hw.constant 0 : i64
  %49 = comb.icmp eq %48, %c : i64
  %50 = comb.and %10, %49 : i1
  %51 = comb.mux %50, %c0_i64_19, %48 : i64
  %52 = comb.mux %10, %51, %c0_i64_19 : i64
  %c1_i64_20 = hw.constant 1 : i64
  %53 = comb.add %4, %c1_i64_20 : i64
  %c0_i64_21 = hw.constant 0 : i64
  %54 = comb.icmp eq %53, %b : i64
  %55 = comb.and %50, %54 : i1
  %56 = comb.mux %55, %c0_i64_21, %53 : i64
  %57 = comb.mux %50, %56, %4 : i64
  %c1_i64_22 = hw.constant 1 : i64
  %58 = comb.add %1, %c1_i64_22 : i64
  %c0_i64_23 = hw.constant 0 : i64
  %59 = comb.icmp eq %58, %a : i64
  %60 = comb.and %55, %59 : i1
  %61 = comb.mux %60, %c0_i64_23, %58 : i64
  %62 = comb.mux %55, %61, %1 : i64
  %false_24 = hw.constant false
  %false_25 = hw.constant false
  %63 = seq.initial() {
    %false_28 = hw.constant false
    seq.yield %false_28 : i1
  } : () -> !seq.immutable<i1>
  %64 = seq.compreg %60, %clk reset %rst, %false_25 initial %63 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_26 = hw.constant 0 : i8
  %c0_i8_27 = hw.constant 0 : i8
  %65 = seq.initial() {
    %c0_i8_28 = hw.constant 0 : i8
    seq.yield %c0_i8_28 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %66, %clk, %64 reset %rst, %c0_i8_27 initial %65 : i8  
  %66 = comb.add %reg_2, %c1_i8 : i8
  hw.output %reg_1 : i8
}
