hw.module @SequencedLoops(in %n : i64, in %m : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %40, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %n : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %52, %clk, %53 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %57, %clk, %58 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %62, %clk, %63 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %67, %clk, %68 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %7 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_4 = seq.compreg.ce sym @mem_0_4 %72, %clk, %73 reset %rst, %c0_i8_5 initial %7 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_5 = seq.compreg.ce sym @mem_0_5 %77, %clk, %78 reset %rst, %c0_i8_6 initial %8 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %9 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_6 = seq.compreg.ce sym @mem_0_6 %82, %clk, %83 reset %rst, %c0_i8_7 initial %9 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_7 = seq.compreg.ce sym @mem_0_7 %87, %clk, %88 reset %rst, %c0_i8_8 initial %10 : i8  
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
  %36 = seq.compreg %89, %clk reset %rst, %c0_i8_11 initial %35 : i8  
  %c1_i64_12 = hw.constant 1 : i64
  %37 = comb.add %1, %c1_i64_12 : i64
  %c0_i64_13 = hw.constant 0 : i64
  %38 = comb.icmp eq %37, %n : i64
  %39 = comb.and %2, %38 : i1
  %40 = comb.mux %2, %37, %1 : i64
  %false_14 = hw.constant false
  %false_15 = hw.constant false
  %41 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %42 = seq.compreg %39, %clk reset %rst, %false_15 initial %41 : i1  
  %c0_i64_16 = hw.constant 0 : i64
  %c0_i64_17 = hw.constant 0 : i64
  %43 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %44 = seq.compreg %93, %clk reset %rst, %c0_i64_17 initial %43 : i64  
  %false_18 = hw.constant false
  %false_19 = hw.constant false
  %45 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %46 = seq.compreg %95, %clk reset %rst, %false_19 initial %45 : i1  
  %47 = comb.icmp ult %44, %m : i64
  %48 = comb.and %46, %47 : i1
  %c0_i64_20 = hw.constant 0 : i64
  %49 = comb.icmp eq %44, %c0_i64_20 : i64
  %50 = comb.and %en, %49 : i1
  %51 = comb.and %48, %50 : i1
  %52 = comb.mux %51, %wd, %wd : i8
  %53 = comb.or %13, %51 : i1
  %c1_i64_21 = hw.constant 1 : i64
  %54 = comb.icmp eq %44, %c1_i64_21 : i64
  %55 = comb.and %en, %54 : i1
  %56 = comb.and %48, %55 : i1
  %57 = comb.mux %56, %wd, %wd : i8
  %58 = comb.or %16, %56 : i1
  %c2_i64_22 = hw.constant 2 : i64
  %59 = comb.icmp eq %44, %c2_i64_22 : i64
  %60 = comb.and %en, %59 : i1
  %61 = comb.and %48, %60 : i1
  %62 = comb.mux %61, %wd, %wd : i8
  %63 = comb.or %19, %61 : i1
  %c3_i64_23 = hw.constant 3 : i64
  %64 = comb.icmp eq %44, %c3_i64_23 : i64
  %65 = comb.and %en, %64 : i1
  %66 = comb.and %48, %65 : i1
  %67 = comb.mux %66, %wd, %wd : i8
  %68 = comb.or %22, %66 : i1
  %c4_i64_24 = hw.constant 4 : i64
  %69 = comb.icmp eq %44, %c4_i64_24 : i64
  %70 = comb.and %en, %69 : i1
  %71 = comb.and %48, %70 : i1
  %72 = comb.mux %71, %wd, %wd : i8
  %73 = comb.or %25, %71 : i1
  %c5_i64_25 = hw.constant 5 : i64
  %74 = comb.icmp eq %44, %c5_i64_25 : i64
  %75 = comb.and %en, %74 : i1
  %76 = comb.and %48, %75 : i1
  %77 = comb.mux %76, %wd, %wd : i8
  %78 = comb.or %28, %76 : i1
  %c6_i64_26 = hw.constant 6 : i64
  %79 = comb.icmp eq %44, %c6_i64_26 : i64
  %80 = comb.and %en, %79 : i1
  %81 = comb.and %48, %80 : i1
  %82 = comb.mux %81, %wd, %wd : i8
  %83 = comb.or %31, %81 : i1
  %c7_i64_27 = hw.constant 7 : i64
  %84 = comb.icmp eq %44, %c7_i64_27 : i64
  %85 = comb.and %en, %84 : i1
  %86 = comb.and %48, %85 : i1
  %87 = comb.mux %86, %wd, %wd : i8
  %88 = comb.or %34, %86 : i1
  %89 = comb.mux %48, %wd, %wd : i8
  %c1_i64_28 = hw.constant 1 : i64
  %90 = comb.add %44, %c1_i64_28 : i64
  %c0_i64_29 = hw.constant 0 : i64
  %91 = comb.icmp eq %90, %m : i64
  %92 = comb.and %48, %91 : i1
  %93 = comb.mux %48, %90, %c0_i64_29 : i64
  %true = hw.constant true
  %false_30 = hw.constant false
  %94 = comb.mux %92, %false_30, %46 : i1
  %95 = comb.mux %42, %true, %94 : i1
  %false_31 = hw.constant false
  %false_32 = hw.constant false
  %96 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %97 = seq.compreg %92, %clk reset %rst, %false_32 initial %96 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_33 = hw.constant 0 : i8
  %c0_i8_34 = hw.constant 0 : i8
  %98 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %99, %clk, %97 reset %rst, %c0_i8_34 initial %98 : i8  
  %99 = comb.add %reg_2, %c1_i8 : i8
  hw.output %36 : i8
}
hw.module @SequencedWhile(in %n : i64, in %m : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %40, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %n : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %52, %clk, %53 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %57, %clk, %58 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %62, %clk, %63 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %67, %clk, %68 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i8_5 = hw.constant 0 : i8
  %7 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_4 = seq.compreg.ce sym @mem_0_4 %72, %clk, %73 reset %rst, %c0_i8_5 initial %7 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_5 = seq.compreg.ce sym @mem_0_5 %77, %clk, %78 reset %rst, %c0_i8_6 initial %8 : i8  
  %c0_i8_7 = hw.constant 0 : i8
  %9 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_6 = seq.compreg.ce sym @mem_0_6 %82, %clk, %83 reset %rst, %c0_i8_7 initial %9 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_7 = seq.compreg.ce sym @mem_0_7 %87, %clk, %88 reset %rst, %c0_i8_8 initial %10 : i8  
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
  %36 = seq.compreg %89, %clk reset %rst, %c0_i8_11 initial %35 : i8  
  %c1_i64_12 = hw.constant 1 : i64
  %37 = comb.add %1, %c1_i64_12 : i64
  %c0_i64_13 = hw.constant 0 : i64
  %38 = comb.icmp eq %37, %n : i64
  %39 = comb.and %2, %38 : i1
  %40 = comb.mux %2, %37, %1 : i64
  %false_14 = hw.constant false
  %false_15 = hw.constant false
  %41 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %42 = seq.compreg %39, %clk reset %rst, %false_15 initial %41 : i1  
  %c0_i64_16 = hw.constant 0 : i64
  %c0_i64_17 = hw.constant 0 : i64
  %43 = seq.initial() {
    %c0_i64_35 = hw.constant 0 : i64
    seq.yield %c0_i64_35 : i64
  } : () -> !seq.immutable<i64>
  %44 = seq.compreg %93, %clk reset %rst, %c0_i64_17 initial %43 : i64  
  %false_18 = hw.constant false
  %false_19 = hw.constant false
  %45 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %46 = seq.compreg %95, %clk reset %rst, %false_19 initial %45 : i1  
  %47 = comb.icmp ult %44, %m : i64
  %48 = comb.and %46, %47 : i1
  %c0_i64_20 = hw.constant 0 : i64
  %49 = comb.icmp eq %44, %c0_i64_20 : i64
  %50 = comb.and %en, %49 : i1
  %51 = comb.and %48, %50 : i1
  %52 = comb.mux %51, %wd, %wd : i8
  %53 = comb.or %13, %51 : i1
  %c1_i64_21 = hw.constant 1 : i64
  %54 = comb.icmp eq %44, %c1_i64_21 : i64
  %55 = comb.and %en, %54 : i1
  %56 = comb.and %48, %55 : i1
  %57 = comb.mux %56, %wd, %wd : i8
  %58 = comb.or %16, %56 : i1
  %c2_i64_22 = hw.constant 2 : i64
  %59 = comb.icmp eq %44, %c2_i64_22 : i64
  %60 = comb.and %en, %59 : i1
  %61 = comb.and %48, %60 : i1
  %62 = comb.mux %61, %wd, %wd : i8
  %63 = comb.or %19, %61 : i1
  %c3_i64_23 = hw.constant 3 : i64
  %64 = comb.icmp eq %44, %c3_i64_23 : i64
  %65 = comb.and %en, %64 : i1
  %66 = comb.and %48, %65 : i1
  %67 = comb.mux %66, %wd, %wd : i8
  %68 = comb.or %22, %66 : i1
  %c4_i64_24 = hw.constant 4 : i64
  %69 = comb.icmp eq %44, %c4_i64_24 : i64
  %70 = comb.and %en, %69 : i1
  %71 = comb.and %48, %70 : i1
  %72 = comb.mux %71, %wd, %wd : i8
  %73 = comb.or %25, %71 : i1
  %c5_i64_25 = hw.constant 5 : i64
  %74 = comb.icmp eq %44, %c5_i64_25 : i64
  %75 = comb.and %en, %74 : i1
  %76 = comb.and %48, %75 : i1
  %77 = comb.mux %76, %wd, %wd : i8
  %78 = comb.or %28, %76 : i1
  %c6_i64_26 = hw.constant 6 : i64
  %79 = comb.icmp eq %44, %c6_i64_26 : i64
  %80 = comb.and %en, %79 : i1
  %81 = comb.and %48, %80 : i1
  %82 = comb.mux %81, %wd, %wd : i8
  %83 = comb.or %31, %81 : i1
  %c7_i64_27 = hw.constant 7 : i64
  %84 = comb.icmp eq %44, %c7_i64_27 : i64
  %85 = comb.and %en, %84 : i1
  %86 = comb.and %48, %85 : i1
  %87 = comb.mux %86, %wd, %wd : i8
  %88 = comb.or %34, %86 : i1
  %89 = comb.mux %48, %wd, %wd : i8
  %c1_i64_28 = hw.constant 1 : i64
  %90 = comb.add %44, %c1_i64_28 : i64
  %c0_i64_29 = hw.constant 0 : i64
  %91 = comb.icmp eq %90, %m : i64
  %92 = comb.and %48, %91 : i1
  %93 = comb.mux %48, %90, %c0_i64_29 : i64
  %true = hw.constant true
  %false_30 = hw.constant false
  %94 = comb.mux %92, %false_30, %46 : i1
  %95 = comb.mux %42, %true, %94 : i1
  %false_31 = hw.constant false
  %false_32 = hw.constant false
  %96 = seq.initial() {
    %false_35 = hw.constant false
    seq.yield %false_35 : i1
  } : () -> !seq.immutable<i1>
  %97 = seq.compreg %92, %clk reset %rst, %false_32 initial %96 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_33 = hw.constant 0 : i8
  %c0_i8_34 = hw.constant 0 : i8
  %98 = seq.initial() {
    %c0_i8_35 = hw.constant 0 : i8
    seq.yield %c0_i8_35 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %99, %clk, %97 reset %rst, %c0_i8_34 initial %98 : i8  
  %99 = comb.add %reg_2, %c1_i8 : i8
  hw.output %36 : i8
}
