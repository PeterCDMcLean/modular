hw.module @LogicMem(in %addr : i64, in %wd : i8, in %wd_xz : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c1_i8 = hw.constant 1 : i8
  %0 = seq.initial() {
    %c1_i8_7 = hw.constant 1 : i8
    seq.yield %c1_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %9 reset %rst, %c1_i8 initial %0 : i8  
  %c0_i8_0 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0_xz = seq.compreg.ce sym @mem_0_0_xz %wd_xz, %clk, %9 reset %rst, %c0_i8_0 initial %1 : i8  
  %c2_i8 = hw.constant 2 : i8
  %2 = seq.initial() {
    %c2_i8_7 = hw.constant 2 : i8
    seq.yield %c2_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %11 reset %rst, %c2_i8 initial %2 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1_xz = seq.compreg.ce sym @mem_0_1_xz %wd_xz, %clk, %11 reset %rst, %c0_i8_1 initial %3 : i8  
  %c3_i8 = hw.constant 3 : i8
  %4 = seq.initial() {
    %c3_i8_7 = hw.constant 3 : i8
    seq.yield %c3_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %13 reset %rst, %c3_i8 initial %4 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %5 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2_xz = seq.compreg.ce sym @mem_0_2_xz %wd_xz, %clk, %13 reset %rst, %c0_i8_2 initial %5 : i8  
  %c4_i8 = hw.constant 4 : i8
  %6 = seq.initial() {
    %c4_i8_7 = hw.constant 4 : i8
    seq.yield %c4_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %15 reset %rst, %c4_i8 initial %6 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %7 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3_xz = seq.compreg.ce sym @mem_0_3_xz %wd_xz, %clk, %15 reset %rst, %c0_i8_3 initial %7 : i8  
  %c0_i64 = hw.constant 0 : i64
  %8 = comb.icmp eq %addr, %c0_i64 : i64
  %9 = comb.and %we, %8 : i1
  %c1_i64 = hw.constant 1 : i64
  %10 = comb.icmp eq %addr, %c1_i64 : i64
  %11 = comb.and %we, %10 : i1
  %c2_i64 = hw.constant 2 : i64
  %12 = comb.icmp eq %addr, %c2_i64 : i64
  %13 = comb.and %we, %12 : i1
  %c3_i64 = hw.constant 3 : i64
  %14 = comb.icmp eq %addr, %c3_i64 : i64
  %15 = comb.and %we, %14 : i1
  %c1_i64_4 = hw.constant 1 : i64
  %16 = comb.icmp eq %addr, %c1_i64_4 : i64
  %17 = comb.mux %16, %mem_0_1, %mem_0_0 : i8
  %18 = comb.mux %16, %mem_0_1_xz, %mem_0_0_xz : i8
  %c2_i64_5 = hw.constant 2 : i64
  %19 = comb.icmp eq %addr, %c2_i64_5 : i64
  %20 = comb.mux %19, %mem_0_2, %17 : i8
  %21 = comb.mux %19, %mem_0_2_xz, %18 : i8
  %c3_i64_6 = hw.constant 3 : i64
  %22 = comb.icmp eq %addr, %c3_i64_6 : i64
  %23 = comb.mux %22, %mem_0_3, %20 : i8
  %24 = comb.mux %22, %mem_0_3_xz, %21 : i8
  hw.output %23, %24 : i8, i8
}
