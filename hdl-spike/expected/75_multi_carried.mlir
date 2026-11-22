hw.module @MultiCarriedSequence(in %n : i64, in %m : i64, in %wa : i8, in %wa_xz : i8, in %wb : i8, in %wb_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_60 = hw.constant 0 : i64
    seq.yield %c0_i64_60 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %115, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_60 = hw.constant false
    seq.yield %false_60 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %114, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %118, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %7 = seq.compreg %119, %clk reset %rst, %c0_i8_5 initial %6 : i8  
  %c0_i8_6 = hw.constant 0 : i8
  %c0_i8_7 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %9 = seq.compreg %120, %clk reset %rst, %c0_i8_7 initial %8 : i8  
  %c0_i8_8 = hw.constant 0 : i8
  %c0_i8_9 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %11 = seq.compreg %121, %clk reset %rst, %c0_i8_9 initial %10 : i8  
  %c0_i8_10 = hw.constant 0 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %12 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %13 = seq.compreg %116, %clk reset %rst, %c0_i8_11 initial %12 : i8  
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %14 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %15 = seq.compreg %117, %clk reset %rst, %c0_i8_13 initial %14 : i8  
  %16 = comb.icmp ult %1, %n : i64
  %17 = comb.and %3, %16 : i1
  %18 = comb.or %7, %wa_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %19 = comb.xor %5, %c-1_i8 : i8
  %20 = comb.or %7, %19 : i8
  %c-1_i8_14 = hw.constant -1 : i8
  %21 = comb.xor %wa, %c-1_i8_14 : i8
  %22 = comb.or %wa_xz, %21 : i8
  %23 = comb.and %18, %20 : i8
  %24 = comb.and %23, %22 : i8
  %25 = comb.or %5, %wa : i8
  %26 = comb.mux %17, %25, %5 : i8
  %27 = comb.mux %17, %24, %7 : i8
  %28 = comb.or %11, %wb_xz : i8
  %29 = comb.or %11, %9 : i8
  %30 = comb.or %wb_xz, %wb : i8
  %31 = comb.and %28, %29 : i8
  %32 = comb.and %31, %30 : i8
  %33 = comb.and %9, %wb : i8
  %34 = comb.mux %17, %33, %9 : i8
  %35 = comb.mux %17, %32, %11 : i8
  %c1_i8 = hw.constant 1 : i8
  %36 = comb.add %13, %c1_i8 : i8
  %37 = comb.mux %17, %36, %13 : i8
  %c2_i8 = hw.constant 2 : i8
  %38 = comb.add %15, %c2_i8 : i8
  %39 = comb.mux %17, %38, %15 : i8
  %40 = comb.mux %3, %26, %wa : i8
  %41 = comb.mux %3, %27, %wa_xz : i8
  %42 = comb.mux %3, %34, %wb : i8
  %43 = comb.mux %3, %35, %wb_xz : i8
  %44 = comb.mux %3, %37, %c0_i8 : i8
  %45 = comb.mux %3, %39, %c3_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %46 = comb.add %1, %c1_i64 : i64
  %c0_i64_15 = hw.constant 0 : i64
  %47 = comb.icmp eq %46, %n : i64
  %48 = comb.and %17, %47 : i1
  %49 = comb.mux %17, %46, %1 : i64
  %false_16 = hw.constant false
  %false_17 = hw.constant false
  %50 = seq.initial() {
    %false_60 = hw.constant false
    seq.yield %false_60 : i1
  } : () -> !seq.immutable<i1>
  %51 = seq.compreg %48, %clk reset %rst, %false_17 initial %50 : i1  
  %true = hw.constant true
  %52 = comb.xor %48, %true : i1
  %true_18 = hw.constant true
  %53 = comb.mux %3, %52, %true_18 : i1
  %c0_i64_19 = hw.constant 0 : i64
  %c0_i64_20 = hw.constant 0 : i64
  %54 = seq.initial() {
    %c0_i64_60 = hw.constant 0 : i64
    seq.yield %c0_i64_60 : i64
  } : () -> !seq.immutable<i64>
  %55 = seq.compreg %106, %clk reset %rst, %c0_i64_20 initial %54 : i64  
  %false_21 = hw.constant false
  %false_22 = hw.constant false
  %56 = seq.initial() {
    %false_60 = hw.constant false
    seq.yield %false_60 : i1
  } : () -> !seq.immutable<i1>
  %57 = seq.compreg %108, %clk reset %rst, %false_22 initial %56 : i1  
  %false_23 = hw.constant false
  %false_24 = hw.constant false
  %58 = seq.initial() {
    %false_60 = hw.constant false
    seq.yield %false_60 : i1
  } : () -> !seq.immutable<i1>
  %59 = seq.compreg %113, %clk reset %rst, %false_24 initial %58 : i1  
  %c0_i8_25 = hw.constant 0 : i8
  %c0_i8_26 = hw.constant 0 : i8
  %60 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %61 = seq.compreg %97, %clk reset %rst, %c0_i8_26 initial %60 : i8  
  %c0_i8_27 = hw.constant 0 : i8
  %c0_i8_28 = hw.constant 0 : i8
  %62 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %63 = seq.compreg %98, %clk reset %rst, %c0_i8_28 initial %62 : i8  
  %c0_i8_29 = hw.constant 0 : i8
  %c0_i8_30 = hw.constant 0 : i8
  %64 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %65 = seq.compreg %99, %clk reset %rst, %c0_i8_30 initial %64 : i8  
  %c0_i8_31 = hw.constant 0 : i8
  %c0_i8_32 = hw.constant 0 : i8
  %66 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %67 = seq.compreg %100, %clk reset %rst, %c0_i8_32 initial %66 : i8  
  %c0_i8_33 = hw.constant 0 : i8
  %c0_i8_34 = hw.constant 0 : i8
  %68 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %69 = seq.compreg %101, %clk reset %rst, %c0_i8_34 initial %68 : i8  
  %c0_i8_35 = hw.constant 0 : i8
  %c0_i8_36 = hw.constant 0 : i8
  %70 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %71 = seq.compreg %102, %clk reset %rst, %c0_i8_36 initial %70 : i8  
  %72 = comb.icmp ult %55, %m : i64
  %73 = comb.and %59, %72 : i1
  %74 = comb.and %57, %73 : i1
  %75 = comb.or %63, %wa_xz : i8
  %c-1_i8_37 = hw.constant -1 : i8
  %76 = comb.xor %61, %c-1_i8_37 : i8
  %77 = comb.or %63, %76 : i8
  %c-1_i8_38 = hw.constant -1 : i8
  %78 = comb.xor %wa, %c-1_i8_38 : i8
  %79 = comb.or %wa_xz, %78 : i8
  %80 = comb.and %75, %77 : i8
  %81 = comb.and %80, %79 : i8
  %82 = comb.or %61, %wa : i8
  %83 = comb.mux %74, %82, %61 : i8
  %84 = comb.mux %74, %81, %63 : i8
  %85 = comb.or %67, %wb_xz : i8
  %86 = comb.or %67, %65 : i8
  %87 = comb.or %wb_xz, %wb : i8
  %88 = comb.and %85, %86 : i8
  %89 = comb.and %88, %87 : i8
  %90 = comb.and %65, %wb : i8
  %91 = comb.mux %74, %90, %65 : i8
  %92 = comb.mux %74, %89, %67 : i8
  %c1_i8_39 = hw.constant 1 : i8
  %93 = comb.add %69, %c1_i8_39 : i8
  %94 = comb.mux %74, %93, %69 : i8
  %c2_i8_40 = hw.constant 2 : i8
  %95 = comb.add %71, %c2_i8_40 : i8
  %96 = comb.mux %74, %95, %71 : i8
  %97 = comb.mux %59, %83, %5 : i8
  %98 = comb.mux %59, %84, %7 : i8
  %99 = comb.mux %59, %91, %9 : i8
  %100 = comb.mux %59, %92, %11 : i8
  %101 = comb.mux %59, %94, %13 : i8
  %102 = comb.mux %59, %96, %15 : i8
  %c1_i64_41 = hw.constant 1 : i64
  %103 = comb.add %55, %c1_i64_41 : i64
  %c0_i64_42 = hw.constant 0 : i64
  %104 = comb.icmp eq %103, %m : i64
  %105 = comb.and %74, %104 : i1
  %106 = comb.mux %74, %103, %c0_i64_42 : i64
  %false_43 = hw.constant false
  %107 = comb.mux %105, %false_43, %57 : i1
  %108 = comb.mux %51, %true_18, %107 : i1
  %false_44 = hw.constant false
  %false_45 = hw.constant false
  %109 = seq.initial() {
    %false_60 = hw.constant false
    seq.yield %false_60 : i1
  } : () -> !seq.immutable<i1>
  %110 = seq.compreg %105, %clk reset %rst, %false_45 initial %109 : i1  
  %true_46 = hw.constant true
  %111 = comb.xor %105, %true_46 : i1
  %112 = comb.mux %59, %111, %true_18 : i1
  %113 = comb.mux %57, %112, %false_43 : i1
  %114 = comb.mux %110, %false_43, %true_18 : i1
  %c0_i64_47 = hw.constant 0 : i64
  %115 = comb.mux %110, %c0_i64_47, %49 : i64
  %116 = comb.mux %110, %c0_i8, %44 : i8
  %117 = comb.mux %110, %c3_i8, %45 : i8
  %118 = comb.mux %110, %wa, %40 : i8
  %119 = comb.mux %110, %wa_xz, %41 : i8
  %120 = comb.mux %110, %wb, %42 : i8
  %121 = comb.mux %110, %wb_xz, %43 : i8
  %c0_i8_48 = hw.constant 0 : i8
  %c0_i8_49 = hw.constant 0 : i8
  %122 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %123 = seq.compreg %126, %clk reset %rst, %c0_i8_49 initial %122 : i8  
  %c0_i8_50 = hw.constant 0 : i8
  %c0_i8_51 = hw.constant 0 : i8
  %124 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %125 = seq.compreg %127, %clk reset %rst, %c0_i8_51 initial %124 : i8  
  %126 = comb.mux %110, %61, %123 : i8
  %127 = comb.mux %110, %63, %125 : i8
  %c0_i8_52 = hw.constant 0 : i8
  %c0_i8_53 = hw.constant 0 : i8
  %128 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %129 = seq.compreg %132, %clk reset %rst, %c0_i8_53 initial %128 : i8  
  %c0_i8_54 = hw.constant 0 : i8
  %c0_i8_55 = hw.constant 0 : i8
  %130 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %131 = seq.compreg %133, %clk reset %rst, %c0_i8_55 initial %130 : i8  
  %132 = comb.mux %110, %65, %129 : i8
  %133 = comb.mux %110, %67, %131 : i8
  %c0_i8_56 = hw.constant 0 : i8
  %c0_i8_57 = hw.constant 0 : i8
  %134 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %69, %clk, %110 reset %rst, %c0_i8_57 initial %134 : i8  
  %c0_i8_58 = hw.constant 0 : i8
  %c0_i8_59 = hw.constant 0 : i8
  %135 = seq.initial() {
    %c0_i8_60 = hw.constant 0 : i8
    seq.yield %c0_i8_60 : i8
  } : () -> !seq.immutable<i8>
  %reg_3 = seq.compreg.ce sym @reg_3 %71, %clk, %110 reset %rst, %c0_i8_59 initial %135 : i8  
  hw.output %123, %125 : i8, i8
}
