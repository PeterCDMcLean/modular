hw.module @MemDualRead(in %addr_a : i64, in %addr_b : i64, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c1_i8 = hw.constant 1 : i8
  %0 = seq.initial() {
    %c1_i8_3 = hw.constant 1 : i8
    seq.yield %c1_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %mem_0_0, %clk, %false reset %rst, %c1_i8 initial %0 : i8  
  %c2_i8 = hw.constant 2 : i8
  %1 = seq.initial() {
    %c2_i8_3 = hw.constant 2 : i8
    seq.yield %c2_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %mem_0_1, %clk, %false reset %rst, %c2_i8 initial %1 : i8  
  %c3_i8 = hw.constant 3 : i8
  %2 = seq.initial() {
    %c3_i8_3 = hw.constant 3 : i8
    seq.yield %c3_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %mem_0_2, %clk, %false reset %rst, %c3_i8 initial %2 : i8  
  %c4_i8 = hw.constant 4 : i8
  %3 = seq.initial() {
    %c4_i8_3 = hw.constant 4 : i8
    seq.yield %c4_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %mem_0_3, %clk, %false reset %rst, %c4_i8 initial %3 : i8  
  %c1_i64 = hw.constant 1 : i64
  %4 = comb.icmp eq %addr_a, %c1_i64 : i64
  %5 = comb.mux %4, %mem_0_1, %mem_0_0 : i8
  %c2_i64 = hw.constant 2 : i64
  %6 = comb.icmp eq %addr_a, %c2_i64 : i64
  %7 = comb.mux %6, %mem_0_2, %5 : i8
  %c3_i64 = hw.constant 3 : i64
  %8 = comb.icmp eq %addr_a, %c3_i64 : i64
  %9 = comb.mux %8, %mem_0_3, %7 : i8
  %c1_i64_0 = hw.constant 1 : i64
  %10 = comb.icmp eq %addr_b, %c1_i64_0 : i64
  %11 = comb.mux %10, %mem_0_1, %mem_0_0 : i8
  %c2_i64_1 = hw.constant 2 : i64
  %12 = comb.icmp eq %addr_b, %c2_i64_1 : i64
  %13 = comb.mux %12, %mem_0_2, %11 : i8
  %c3_i64_2 = hw.constant 3 : i64
  %14 = comb.icmp eq %addr_b, %c3_i64_2 : i64
  %15 = comb.mux %14, %mem_0_3, %13 : i8
  %16 = comb.xor %9, %15 : i8
  hw.output %16 : i8
}
