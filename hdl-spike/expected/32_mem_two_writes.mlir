hw.module @MemTwoWrites(in %wa : i64, in %wd : i8, in %we : i1, in %wb : i64, in %wd2 : i8, in %we2 : i1, in %ra : i64, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c1_i8 = hw.constant 1 : i8
  %0 = seq.initial() {
    %c1_i8_7 = hw.constant 1 : i8
    seq.yield %c1_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %14, %clk, %15 reset %rst, %c1_i8 initial %0 : i8  
  %c2_i8 = hw.constant 2 : i8
  %1 = seq.initial() {
    %c2_i8_7 = hw.constant 2 : i8
    seq.yield %c2_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %18, %clk, %19 reset %rst, %c2_i8 initial %1 : i8  
  %c3_i8 = hw.constant 3 : i8
  %2 = seq.initial() {
    %c3_i8_7 = hw.constant 3 : i8
    seq.yield %c3_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %22, %clk, %23 reset %rst, %c3_i8 initial %2 : i8  
  %c4_i8 = hw.constant 4 : i8
  %3 = seq.initial() {
    %c4_i8_7 = hw.constant 4 : i8
    seq.yield %c4_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %26, %clk, %27 reset %rst, %c4_i8 initial %3 : i8  
  %c0_i64 = hw.constant 0 : i64
  %4 = comb.icmp eq %wa, %c0_i64 : i64
  %5 = comb.and %we, %4 : i1
  %c1_i64 = hw.constant 1 : i64
  %6 = comb.icmp eq %wa, %c1_i64 : i64
  %7 = comb.and %we, %6 : i1
  %c2_i64 = hw.constant 2 : i64
  %8 = comb.icmp eq %wa, %c2_i64 : i64
  %9 = comb.and %we, %8 : i1
  %c3_i64 = hw.constant 3 : i64
  %10 = comb.icmp eq %wa, %c3_i64 : i64
  %11 = comb.and %we, %10 : i1
  %c0_i64_0 = hw.constant 0 : i64
  %12 = comb.icmp eq %wb, %c0_i64_0 : i64
  %13 = comb.and %we2, %12 : i1
  %14 = comb.mux %13, %wd2, %wd : i8
  %15 = comb.or %5, %13 : i1
  %c1_i64_1 = hw.constant 1 : i64
  %16 = comb.icmp eq %wb, %c1_i64_1 : i64
  %17 = comb.and %we2, %16 : i1
  %18 = comb.mux %17, %wd2, %wd : i8
  %19 = comb.or %7, %17 : i1
  %c2_i64_2 = hw.constant 2 : i64
  %20 = comb.icmp eq %wb, %c2_i64_2 : i64
  %21 = comb.and %we2, %20 : i1
  %22 = comb.mux %21, %wd2, %wd : i8
  %23 = comb.or %9, %21 : i1
  %c3_i64_3 = hw.constant 3 : i64
  %24 = comb.icmp eq %wb, %c3_i64_3 : i64
  %25 = comb.and %we2, %24 : i1
  %26 = comb.mux %25, %wd2, %wd : i8
  %27 = comb.or %11, %25 : i1
  %c1_i64_4 = hw.constant 1 : i64
  %28 = comb.icmp eq %ra, %c1_i64_4 : i64
  %29 = comb.mux %28, %mem_0_1, %mem_0_0 : i8
  %c2_i64_5 = hw.constant 2 : i64
  %30 = comb.icmp eq %ra, %c2_i64_5 : i64
  %31 = comb.mux %30, %mem_0_2, %29 : i8
  %c3_i64_6 = hw.constant 3 : i64
  %32 = comb.icmp eq %ra, %c3_i64_6 : i64
  %33 = comb.mux %32, %mem_0_3, %31 : i8
  hw.output %33 : i8
}
