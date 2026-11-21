hw.module @BareArray(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %5 reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %7 reset %rst, %c0_i8_1 initial %1 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wd, %clk, %9 reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_7 = hw.constant 0 : i8
    seq.yield %c0_i8_7 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wd, %clk, %11 reset %rst, %c0_i8_3 initial %3 : i8  
  %c0_i64 = hw.constant 0 : i64
  %4 = comb.icmp eq %addr, %c0_i64 : i64
  %5 = comb.and %we, %4 : i1
  %c1_i64 = hw.constant 1 : i64
  %6 = comb.icmp eq %addr, %c1_i64 : i64
  %7 = comb.and %we, %6 : i1
  %c2_i64 = hw.constant 2 : i64
  %8 = comb.icmp eq %addr, %c2_i64 : i64
  %9 = comb.and %we, %8 : i1
  %c3_i64 = hw.constant 3 : i64
  %10 = comb.icmp eq %addr, %c3_i64 : i64
  %11 = comb.and %we, %10 : i1
  %c1_i64_4 = hw.constant 1 : i64
  %12 = comb.icmp eq %addr, %c1_i64_4 : i64
  %13 = comb.mux %12, %mem_0_1, %mem_0_0 : i8
  %c2_i64_5 = hw.constant 2 : i64
  %14 = comb.icmp eq %addr, %c2_i64_5 : i64
  %15 = comb.mux %14, %mem_0_2, %13 : i8
  %c3_i64_6 = hw.constant 3 : i64
  %16 = comb.icmp eq %addr, %c3_i64_6 : i64
  %17 = comb.mux %16, %mem_0_3, %15 : i8
  hw.output %17 : i8
}
hw.module @LogicArray(in %addr : i64, in %wd : i8, in %wd_xz : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %5 reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0_xz = seq.compreg.ce sym @mem_0_0_xz %wd_xz, %clk, %5 reset %rst, %c0_i8_1 initial %1 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wd, %clk, %7 reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1_xz = seq.compreg.ce sym @mem_0_1_xz %wd_xz, %clk, %7 reset %rst, %c0_i8_3 initial %3 : i8  
  %c0_i64 = hw.constant 0 : i64
  %4 = comb.icmp eq %addr, %c0_i64 : i64
  %5 = comb.and %we, %4 : i1
  %c1_i64 = hw.constant 1 : i64
  %6 = comb.icmp eq %addr, %c1_i64 : i64
  %7 = comb.and %we, %6 : i1
  %c1_i64_4 = hw.constant 1 : i64
  %8 = comb.icmp eq %addr, %c1_i64_4 : i64
  %9 = comb.mux %8, %mem_0_1, %mem_0_0 : i8
  %10 = comb.mux %8, %mem_0_1_xz, %mem_0_0_xz : i8
  hw.output %9, %10 : i8, i8
}
hw.module @StaticArray(in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_2 = hw.constant 0 : i8
    seq.yield %c0_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd, %clk, %2 reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_2 = hw.constant 0 : i8
    seq.yield %c0_i8_2 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %c0_i8, %clk, %false reset %rst, %c0_i8_1 initial %1 : i8  
  %true = hw.constant true
  %2 = comb.and %we, %true : i1
  %c1_i64 = hw.constant 1 : i64
  hw.output %mem_0_1 : i8
}
