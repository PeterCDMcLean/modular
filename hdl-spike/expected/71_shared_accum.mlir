hw.module @SharedAccum(in %n : i64, in %m : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_27 = hw.constant 0 : i64
    seq.yield %c0_i64_27 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %20, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %19, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i8_2 = hw.constant 0 : i8
  %c0_i8_3 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %21, %clk reset %rst, %c0_i8_3 initial %4 : i8  
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
  %false_8 = hw.constant false
  %19 = comb.mux %16, %false_8, %true_7 : i1
  %c0_i64_9 = hw.constant 0 : i64
  %20 = comb.mux %16, %c0_i64_9, %14 : i64
  %21 = comb.mux %16, %c0_i8, %10 : i8
  %c0_i64_10 = hw.constant 0 : i64
  %c0_i64_11 = hw.constant 0 : i64
  %22 = seq.initial() {
    %c0_i64_27 = hw.constant 0 : i64
    seq.yield %c0_i64_27 : i64
  } : () -> !seq.immutable<i64>
  %23 = seq.compreg %39, %clk reset %rst, %c0_i64_11 initial %22 : i64  
  %false_12 = hw.constant false
  %false_13 = hw.constant false
  %24 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %25 = seq.compreg %41, %clk reset %rst, %false_13 initial %24 : i1  
  %false_14 = hw.constant false
  %false_15 = hw.constant false
  %26 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %27 = seq.compreg %46, %clk reset %rst, %false_15 initial %26 : i1  
  %c0_i8_16 = hw.constant 0 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %28 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %29 = seq.compreg %35, %clk reset %rst, %c0_i8_17 initial %28 : i8  
  %30 = comb.icmp ult %23, %m : i64
  %31 = comb.and %27, %30 : i1
  %32 = comb.and %25, %31 : i1
  %33 = comb.add %29, %wd : i8
  %34 = comb.mux %32, %33, %29 : i8
  %35 = comb.mux %27, %34, %5 : i8
  %c1_i64_18 = hw.constant 1 : i64
  %36 = comb.add %23, %c1_i64_18 : i64
  %c0_i64_19 = hw.constant 0 : i64
  %37 = comb.icmp eq %36, %m : i64
  %38 = comb.and %32, %37 : i1
  %39 = comb.mux %32, %36, %c0_i64_19 : i64
  %40 = comb.mux %38, %false_8, %25 : i1
  %41 = comb.mux %16, %true_7, %40 : i1
  %false_20 = hw.constant false
  %false_21 = hw.constant false
  %42 = seq.initial() {
    %false_27 = hw.constant false
    seq.yield %false_27 : i1
  } : () -> !seq.immutable<i1>
  %43 = seq.compreg %38, %clk reset %rst, %false_21 initial %42 : i1  
  %true_22 = hw.constant true
  %44 = comb.xor %38, %true_22 : i1
  %45 = comb.mux %27, %44, %true_7 : i1
  %46 = comb.mux %25, %45, %false_8 : i1
  %c0_i8_23 = hw.constant 0 : i8
  %c0_i8_24 = hw.constant 0 : i8
  %47 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %29, %clk, %43 reset %rst, %c0_i8_24 initial %47 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_25 = hw.constant 0 : i8
  %c0_i8_26 = hw.constant 0 : i8
  %48 = seq.initial() {
    %c0_i8_27 = hw.constant 0 : i8
    seq.yield %c0_i8_27 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %49, %clk, %43 reset %rst, %c0_i8_26 initial %48 : i8  
  %49 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
