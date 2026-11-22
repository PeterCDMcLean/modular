hw.module @RuntimeForDone(in %count : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_14 = hw.constant 0 : i64
    seq.yield %c0_i64_14 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %21, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %count : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %9 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %12 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %15 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %18 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i64_5 = hw.constant 0 : i64
  %7 = comb.icmp eq %1, %c0_i64_5 : i64
  %8 = comb.and %en, %7 : i1
  %9 = comb.and %2, %8 : i1
  %c1_i64 = hw.constant 1 : i64
  %10 = comb.icmp eq %1, %c1_i64 : i64
  %11 = comb.and %en, %10 : i1
  %12 = comb.and %2, %11 : i1
  %c2_i64 = hw.constant 2 : i64
  %13 = comb.icmp eq %1, %c2_i64 : i64
  %14 = comb.and %en, %13 : i1
  %15 = comb.and %2, %14 : i1
  %c3_i64 = hw.constant 3 : i64
  %16 = comb.icmp eq %1, %c3_i64 : i64
  %17 = comb.and %en, %16 : i1
  %18 = comb.and %2, %17 : i1
  %c0_i8_6 = hw.constant 0 : i8
  %c0_i8_7 = hw.constant 0 : i8
  %19 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %wd, %clk, %2 reset %rst, %c0_i8_7 initial %19 : i8  
  %c1_i64_8 = hw.constant 1 : i64
  %20 = comb.add %1, %c1_i64_8 : i64
  %c0_i64_9 = hw.constant 0 : i64
  %21 = comb.mux %2, %20, %c0_i64_9 : i64
  %22 = comb.icmp eq %20, %count : i64
  %23 = comb.and %2, %22 : i1
  %false_10 = hw.constant false
  %false_11 = hw.constant false
  %24 = seq.initial() {
    %false_14 = hw.constant false
    seq.yield %false_14 : i1
  } : () -> !seq.immutable<i1>
  %25 = seq.compreg %23, %clk reset %rst, %false_11 initial %24 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %26 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %27, %clk, %25 reset %rst, %c0_i8_13 initial %26 : i8  
  %27 = comb.add %reg_2, %c1_i8 : i8
  hw.output %reg_2 : i8
}
hw.module @RuntimeWhileDone(in %count : i64, in %wd : i8, in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_14 = hw.constant 0 : i64
    seq.yield %c0_i64_14 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %21, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %2 = comb.icmp ult %1, %count : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %9 reset %rst, %c0_i8_1 initial %3 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %12 reset %rst, %c0_i8_2 initial %4 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %15 reset %rst, %c0_i8_3 initial %5 : i8  
  %c0_i8_4 = hw.constant 0 : i8
  %6 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %18 reset %rst, %c0_i8_4 initial %6 : i8  
  %c0_i64_5 = hw.constant 0 : i64
  %7 = comb.icmp eq %1, %c0_i64_5 : i64
  %8 = comb.and %en, %7 : i1
  %9 = comb.and %2, %8 : i1
  %c1_i64 = hw.constant 1 : i64
  %10 = comb.icmp eq %1, %c1_i64 : i64
  %11 = comb.and %en, %10 : i1
  %12 = comb.and %2, %11 : i1
  %c2_i64 = hw.constant 2 : i64
  %13 = comb.icmp eq %1, %c2_i64 : i64
  %14 = comb.and %en, %13 : i1
  %15 = comb.and %2, %14 : i1
  %c3_i64 = hw.constant 3 : i64
  %16 = comb.icmp eq %1, %c3_i64 : i64
  %17 = comb.and %en, %16 : i1
  %18 = comb.and %2, %17 : i1
  %c0_i8_6 = hw.constant 0 : i8
  %c0_i8_7 = hw.constant 0 : i8
  %19 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %wd, %clk, %2 reset %rst, %c0_i8_7 initial %19 : i8  
  %c1_i64_8 = hw.constant 1 : i64
  %20 = comb.add %1, %c1_i64_8 : i64
  %c0_i64_9 = hw.constant 0 : i64
  %21 = comb.mux %2, %20, %c0_i64_9 : i64
  %22 = comb.icmp eq %20, %count : i64
  %23 = comb.and %2, %22 : i1
  %false_10 = hw.constant false
  %false_11 = hw.constant false
  %24 = seq.initial() {
    %false_14 = hw.constant false
    seq.yield %false_14 : i1
  } : () -> !seq.immutable<i1>
  %25 = seq.compreg %23, %clk reset %rst, %false_11 initial %24 : i1  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %c0_i8_13 = hw.constant 0 : i8
  %26 = seq.initial() {
    %c0_i8_14 = hw.constant 0 : i8
    seq.yield %c0_i8_14 : i8
  } : () -> !seq.immutable<i8>
  %reg_2 = seq.compreg.ce sym @reg_2 %27, %clk, %25 reset %rst, %c0_i8_13 initial %26 : i8  
  %27 = comb.add %reg_2, %c1_i8 : i8
  hw.output %reg_2 : i8
}
