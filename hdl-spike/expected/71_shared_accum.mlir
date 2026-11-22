hw.module @SharedAccum(in %n : i64, in %m : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_27 = hw.constant 0 : i64
    seq.yield %c0_i64_27 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %45, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %44, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %46, %clk reset %rst, %c0_i8_3 initial %4 : i8  
  %6 = comb.icmp ult %1, %n : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.add %5, %wd : i8
  %9 = comb.mux %7, %8, %5 : i8
  %10 = comb.mux %3, %9, %c0_i8 : i8
  %c1_i64 = hw.constant 1 : i64
  %11 = comb.add %1, %c1_i64 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %12 = comb.icmp eq %11, %n : i64
  %13 = comb.and %7, %12 : i1
  %14 = comb.mux %7, %11, %1 : i64
  %false_5 = hw.constant false
  %false_6 = hw.constant false
  %15 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %16 = seq.compreg %13, %clk reset %rst, %false_6 initial %15 : i1  
  %true = hw.constant true
  %17 = comb.xor %13, %true : i1
  %true_7 = hw.constant true
  %18 = comb.mux %3, %17, %true_7 : i1
  %c0_i64_8 = hw.constant 0 : i64
  %c0_i64_9 = hw.constant 0 : i64
  %19 = seq.initial() {
    %c0_i64_27 = hw.constant 0 : i64
    seq.yield %c0_i64_27 : i64
  } : () -> !seq.immutable<i64>
  %20 = seq.compreg %36, %clk reset %rst, %c0_i64_9 initial %19 : i64  
  %false_10 = hw.constant false
  %false_11 = hw.constant false
  %21 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %22 = seq.compreg %38, %clk reset %rst, %false_11 initial %21 : i1  
  %false_12 = hw.constant false
  %false_13 = hw.constant false
  %23 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %24 = seq.compreg %43, %clk reset %rst, %false_13 initial %23 : i1  
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %25 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %26 = seq.compreg %32, %clk reset %rst, %c0_i8_15 initial %25 : i8  
  %27 = comb.icmp ult %20, %m : i64
  %28 = comb.and %24, %27 : i1
  %29 = comb.and %22, %28 : i1
  %30 = comb.add %26, %wd : i8
  %31 = comb.mux %29, %30, %26 : i8
  %32 = comb.mux %24, %31, %5 : i8
  %c1_i64_16 = hw.constant 1 : i64
  %33 = comb.add %20, %c1_i64_16 : i64
  %c0_i64_17 = hw.constant 0 : i64
  %34 = comb.icmp eq %33, %m : i64
  %35 = comb.and %29, %34 : i1
  %36 = comb.mux %29, %33, %c0_i64_17 : i64
  %false_18 = hw.constant false
  %37 = comb.mux %35, %false_18, %22 : i1
  %38 = comb.mux %16, %true_7, %37 : i1
  %false_19 = hw.constant false
  %false_20 = hw.constant false
  %39 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %40 = seq.compreg %35, %clk reset %rst, %false_20 initial %39 : i1  
  %true_21 = hw.constant true
  %41 = comb.xor %35, %true_21 : i1
  %42 = comb.mux %24, %41, %true_7 : i1
  %43 = comb.mux %22, %42, %false_18 : i1
  %44 = comb.mux %40, %false_18, %true_7 : i1
  %c0_i64_22 = hw.constant 0 : i64
  %45 = comb.mux %40, %c0_i64_22, %14 : i64
  %46 = comb.mux %40, %c0_i8, %10 : i8
  %c0_i8_23 = hw.constant 0 : i8
  %c0_i8_24 = hw.constant 0 : i8
  %47 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %26, %clk, %40 reset %rst, %c0_i8_24 initial %47 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_25 = hw.constant 0 : i8
  %c0_i8_26 = hw.constant 0 : i8
  %48 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %49, %clk, %40 reset %rst, %c0_i8_26 initial %48 : i8  
  %49 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
