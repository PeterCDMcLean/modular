hw.module @SequencedLoops(in %n : i64, in %m : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %41, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %n : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %53, %clk, %54 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %58, %clk, %59 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %63, %clk, %64 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %68, %clk, %69 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %7 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_4 = seq.compreg.ce sym @mem_0_4 %73, %clk, %74 reset %rst, %c0_i8_5 initial %7 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_5 = seq.compreg.ce sym @mem_0_5 %78, %clk, %79 reset %rst, %c0_i8_6 initial %8 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %9 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_6 = seq.compreg.ce sym @mem_0_6 %83, %clk, %84 reset %rst, %c0_i8_7 initial %9 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_7 = seq.compreg.ce sym @mem_0_7 %88, %clk, %89 reset %rst, %c0_i8_8 initial %10 : i8  
  %c0_i64_9 = hw.constant 0 : i64
  %11 = comb.icmp eq %1, %c0_i64_9 : i64
  %12 = comb.and %en, %11 : i1
  %13 = comb.and %2, %12 : i1
  %c1_i64 = hw.constant 1 : i64
  %14 = comb.icmp eq %1, %c1_i64 : i64
  %15 = comb.and %en, %14 : i1
  %16 = comb.and %2, %15 : i1
  %c2_i64 = hw.constant 2 : i64
  %17 = comb.icmp eq %1, %c2_i64 : i64
  %18 = comb.and %en, %17 : i1
  %19 = comb.and %2, %18 : i1
  %c3_i64 = hw.constant 3 : i64
  %20 = comb.icmp eq %1, %c3_i64 : i64
  %21 = comb.and %en, %20 : i1
  %22 = comb.and %2, %21 : i1
  %c4_i64 = hw.constant 4 : i64
  %23 = comb.icmp eq %1, %c4_i64 : i64
  %24 = comb.and %en, %23 : i1
  %25 = comb.and %2, %24 : i1
  %c5_i64 = hw.constant 5 : i64
  %26 = comb.icmp eq %1, %c5_i64 : i64
  %27 = comb.and %en, %26 : i1
  %28 = comb.and %2, %27 : i1
  %c6_i64 = hw.constant 6 : i64
  %29 = comb.icmp eq %1, %c6_i64 : i64
  %30 = comb.and %en, %29 : i1
  %31 = comb.and %2, %30 : i1
  %c7_i64 = hw.constant 7 : i64
  %32 = comb.icmp eq %1, %c7_i64 : i64
  %33 = comb.and %en, %32 : i1
  %34 = comb.and %2, %33 : i1
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %35 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %36 = comb.mux %2, %wd, %37 : i8
  %37 = seq.compreg %90, %clk reset %rst, %c0_i8_11 initial %35 : i8  
  %c1_i64_12 = hw.constant 1 : i64
  %38 = comb.add %1, %c1_i64_12 : i64
  %c0_i64_13 = hw.constant 0 : i64
  %39 = comb.icmp eq %38, %n : i64
  %40 = comb.and %2, %39 : i1
  %41 = comb.mux %2, %38, %1 : i64
  %false_14 = hw.constant false
  %false_15 = hw.constant false
  %42 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %43 = seq.compreg %40, %clk reset %rst, %false_15 initial %42 : i1  
  %c0_i64_16 = hw.constant 0 : i64
  %c0_i64_17 = hw.constant 0 : i64
  %44 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %45 = seq.compreg %94, %clk reset %rst, %c0_i64_17 initial %44 : i64  
  %false_18 = hw.constant false
  %false_19 = hw.constant false
  %46 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %47 = seq.compreg %96, %clk reset %rst, %false_19 initial %46 : i1  
  %48 = comb.icmp ult %45, %m : i64
  %49 = comb.and %47, %48 : i1
  %c0_i64_20 = hw.constant 0 : i64
  %50 = comb.icmp eq %45, %c0_i64_20 : i64
  %51 = comb.and %en, %50 : i1
  %52 = comb.and %49, %51 : i1
  %53 = comb.mux %52, %wd, %wd : i8
  %54 = comb.or %13, %52 : i1
  %c1_i64_21 = hw.constant 1 : i64
  %55 = comb.icmp eq %45, %c1_i64_21 : i64
  %56 = comb.and %en, %55 : i1
  %57 = comb.and %49, %56 : i1
  %58 = comb.mux %57, %wd, %wd : i8
  %59 = comb.or %16, %57 : i1
  %c2_i64_22 = hw.constant 2 : i64
  %60 = comb.icmp eq %45, %c2_i64_22 : i64
  %61 = comb.and %en, %60 : i1
  %62 = comb.and %49, %61 : i1
  %63 = comb.mux %62, %wd, %wd : i8
  %64 = comb.or %19, %62 : i1
  %c3_i64_23 = hw.constant 3 : i64
  %65 = comb.icmp eq %45, %c3_i64_23 : i64
  %66 = comb.and %en, %65 : i1
  %67 = comb.and %49, %66 : i1
  %68 = comb.mux %67, %wd, %wd : i8
  %69 = comb.or %22, %67 : i1
  %c4_i64_24 = hw.constant 4 : i64
  %70 = comb.icmp eq %45, %c4_i64_24 : i64
  %71 = comb.and %en, %70 : i1
  %72 = comb.and %49, %71 : i1
  %73 = comb.mux %72, %wd, %wd : i8
  %74 = comb.or %25, %72 : i1
  %c5_i64_25 = hw.constant 5 : i64
  %75 = comb.icmp eq %45, %c5_i64_25 : i64
  %76 = comb.and %en, %75 : i1
  %77 = comb.and %49, %76 : i1
  %78 = comb.mux %77, %wd, %wd : i8
  %79 = comb.or %28, %77 : i1
  %c6_i64_26 = hw.constant 6 : i64
  %80 = comb.icmp eq %45, %c6_i64_26 : i64
  %81 = comb.and %en, %80 : i1
  %82 = comb.and %49, %81 : i1
  %83 = comb.mux %82, %wd, %wd : i8
  %84 = comb.or %31, %82 : i1
  %c7_i64_27 = hw.constant 7 : i64
  %85 = comb.icmp eq %45, %c7_i64_27 : i64
  %86 = comb.and %en, %85 : i1
  %87 = comb.and %49, %86 : i1
  %88 = comb.mux %87, %wd, %wd : i8
  %89 = comb.or %34, %87 : i1
  %90 = comb.mux %49, %wd, %36 : i8
  %c1_i64_28 = hw.constant 1 : i64
  %91 = comb.add %45, %c1_i64_28 : i64
  %c0_i64_29 = hw.constant 0 : i64
  %92 = comb.icmp eq %91, %m : i64
  %93 = comb.and %49, %92 : i1
  %94 = comb.mux %49, %91, %c0_i64_29 : i64
  %true = hw.constant true
  %false_30 = hw.constant false
  %95 = comb.mux %93, %false_30, %47 : i1
  %96 = comb.mux %43, %true, %95 : i1
  %false_31 = hw.constant false
  %false_32 = hw.constant false
  %97 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %98 = seq.compreg %93, %clk reset %rst, %false_32 initial %97 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_33 = hw.constant 0 : i8
  %c0_i8_34 = hw.constant 0 : i8
  %99 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %100, %clk, %98 reset %rst, %c0_i8_34 initial %99 : i8  
  %100 = comb.add %reg_2, %c1_i8 : i8
  hw.output %37 : i8
}
hw.module @SequencedWhile(in %n : i64, in %m : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %41, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %n : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %53, %clk, %54 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %58, %clk, %59 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %63, %clk, %64 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %68, %clk, %69 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %7 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_4 = seq.compreg.ce sym @mem_0_4 %73, %clk, %74 reset %rst, %c0_i8_5 initial %7 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_5 = seq.compreg.ce sym @mem_0_5 %78, %clk, %79 reset %rst, %c0_i8_6 initial %8 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %9 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_6 = seq.compreg.ce sym @mem_0_6 %83, %clk, %84 reset %rst, %c0_i8_7 initial %9 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_7 = seq.compreg.ce sym @mem_0_7 %88, %clk, %89 reset %rst, %c0_i8_8 initial %10 : i8  
  %c0_i64_9 = hw.constant 0 : i64
  %11 = comb.icmp eq %1, %c0_i64_9 : i64
  %12 = comb.and %en, %11 : i1
  %13 = comb.and %2, %12 : i1
  %c1_i64 = hw.constant 1 : i64
  %14 = comb.icmp eq %1, %c1_i64 : i64
  %15 = comb.and %en, %14 : i1
  %16 = comb.and %2, %15 : i1
  %c2_i64 = hw.constant 2 : i64
  %17 = comb.icmp eq %1, %c2_i64 : i64
  %18 = comb.and %en, %17 : i1
  %19 = comb.and %2, %18 : i1
  %c3_i64 = hw.constant 3 : i64
  %20 = comb.icmp eq %1, %c3_i64 : i64
  %21 = comb.and %en, %20 : i1
  %22 = comb.and %2, %21 : i1
  %c4_i64 = hw.constant 4 : i64
  %23 = comb.icmp eq %1, %c4_i64 : i64
  %24 = comb.and %en, %23 : i1
  %25 = comb.and %2, %24 : i1
  %c5_i64 = hw.constant 5 : i64
  %26 = comb.icmp eq %1, %c5_i64 : i64
  %27 = comb.and %en, %26 : i1
  %28 = comb.and %2, %27 : i1
  %c6_i64 = hw.constant 6 : i64
  %29 = comb.icmp eq %1, %c6_i64 : i64
  %30 = comb.and %en, %29 : i1
  %31 = comb.and %2, %30 : i1
  %c7_i64 = hw.constant 7 : i64
  %32 = comb.icmp eq %1, %c7_i64 : i64
  %33 = comb.and %en, %32 : i1
  %34 = comb.and %2, %33 : i1
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %35 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %36 = comb.mux %2, %wd, %37 : i8
  %37 = seq.compreg %90, %clk reset %rst, %c0_i8_11 initial %35 : i8  
  %c1_i64_12 = hw.constant 1 : i64
  %38 = comb.add %1, %c1_i64_12 : i64
  %c0_i64_13 = hw.constant 0 : i64
  %39 = comb.icmp eq %38, %n : i64
  %40 = comb.and %2, %39 : i1
  %41 = comb.mux %2, %38, %1 : i64
  %false_14 = hw.constant false
  %false_15 = hw.constant false
  %42 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %43 = seq.compreg %40, %clk reset %rst, %false_15 initial %42 : i1  
  %c0_i64_16 = hw.constant 0 : i64
  %c0_i64_17 = hw.constant 0 : i64
  %44 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %45 = seq.compreg %94, %clk reset %rst, %c0_i64_17 initial %44 : i64  
  %false_18 = hw.constant false
  %false_19 = hw.constant false
  %46 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %47 = seq.compreg %96, %clk reset %rst, %false_19 initial %46 : i1  
  %48 = comb.icmp ult %45, %m : i64
  %49 = comb.and %47, %48 : i1
  %c0_i64_20 = hw.constant 0 : i64
  %50 = comb.icmp eq %45, %c0_i64_20 : i64
  %51 = comb.and %en, %50 : i1
  %52 = comb.and %49, %51 : i1
  %53 = comb.mux %52, %wd, %wd : i8
  %54 = comb.or %13, %52 : i1
  %c1_i64_21 = hw.constant 1 : i64
  %55 = comb.icmp eq %45, %c1_i64_21 : i64
  %56 = comb.and %en, %55 : i1
  %57 = comb.and %49, %56 : i1
  %58 = comb.mux %57, %wd, %wd : i8
  %59 = comb.or %16, %57 : i1
  %c2_i64_22 = hw.constant 2 : i64
  %60 = comb.icmp eq %45, %c2_i64_22 : i64
  %61 = comb.and %en, %60 : i1
  %62 = comb.and %49, %61 : i1
  %63 = comb.mux %62, %wd, %wd : i8
  %64 = comb.or %19, %62 : i1
  %c3_i64_23 = hw.constant 3 : i64
  %65 = comb.icmp eq %45, %c3_i64_23 : i64
  %66 = comb.and %en, %65 : i1
  %67 = comb.and %49, %66 : i1
  %68 = comb.mux %67, %wd, %wd : i8
  %69 = comb.or %22, %67 : i1
  %c4_i64_24 = hw.constant 4 : i64
  %70 = comb.icmp eq %45, %c4_i64_24 : i64
  %71 = comb.and %en, %70 : i1
  %72 = comb.and %49, %71 : i1
  %73 = comb.mux %72, %wd, %wd : i8
  %74 = comb.or %25, %72 : i1
  %c5_i64_25 = hw.constant 5 : i64
  %75 = comb.icmp eq %45, %c5_i64_25 : i64
  %76 = comb.and %en, %75 : i1
  %77 = comb.and %49, %76 : i1
  %78 = comb.mux %77, %wd, %wd : i8
  %79 = comb.or %28, %77 : i1
  %c6_i64_26 = hw.constant 6 : i64
  %80 = comb.icmp eq %45, %c6_i64_26 : i64
  %81 = comb.and %en, %80 : i1
  %82 = comb.and %49, %81 : i1
  %83 = comb.mux %82, %wd, %wd : i8
  %84 = comb.or %31, %82 : i1
  %c7_i64_27 = hw.constant 7 : i64
  %85 = comb.icmp eq %45, %c7_i64_27 : i64
  %86 = comb.and %en, %85 : i1
  %87 = comb.and %49, %86 : i1
  %88 = comb.mux %87, %wd, %wd : i8
  %89 = comb.or %34, %87 : i1
  %90 = comb.mux %49, %wd, %36 : i8
  %c1_i64_28 = hw.constant 1 : i64
  %91 = comb.add %45, %c1_i64_28 : i64
  %c0_i64_29 = hw.constant 0 : i64
  %92 = comb.icmp eq %91, %m : i64
  %93 = comb.and %49, %92 : i1
  %94 = comb.mux %49, %91, %c0_i64_29 : i64
  %true = hw.constant true
  %false_30 = hw.constant false
  %95 = comb.mux %93, %false_30, %47 : i1
  %96 = comb.mux %43, %true, %95 : i1
  %false_31 = hw.constant false
  %false_32 = hw.constant false
  %97 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %98 = seq.compreg %93, %clk reset %rst, %false_32 initial %97 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_33 = hw.constant 0 : i8
  %c0_i8_34 = hw.constant 0 : i8
  %99 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %100, %clk, %98 reset %rst, %c0_i8_34 initial %99 : i8  
  %100 = comb.add %reg_2, %c1_i8 : i8
  hw.output %37 : i8
}
