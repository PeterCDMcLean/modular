hw.module @MemInit(in %addr : i64, in %wdata : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %false = hw.constant false
  %0 = seq.initial() {
    %c5_i8_3 = hw.constant 5 : i8
    seq.yield %c5_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wdata, %clk, %2 reset %rst, %c5_i8 initial %0 : i8  
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wdata, %clk, %4 reset %rst, %c5_i8 initial %0 : i8  
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %wdata, %clk, %6 reset %rst, %c5_i8 initial %0 : i8  
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %wdata, %clk, %8 reset %rst, %c5_i8 initial %0 : i8  
  %c0_i64 = hw.constant 0 : i64
  %1 = comb.icmp eq %addr, %c0_i64 : i64
  %2 = comb.and %we, %1 : i1
  %c1_i64 = hw.constant 1 : i64
  %3 = comb.icmp eq %addr, %c1_i64 : i64
  %4 = comb.and %we, %3 : i1
  %c2_i64 = hw.constant 2 : i64
  %5 = comb.icmp eq %addr, %c2_i64 : i64
  %6 = comb.and %we, %5 : i1
  %c3_i64 = hw.constant 3 : i64
  %7 = comb.icmp eq %addr, %c3_i64 : i64
  %8 = comb.and %we, %7 : i1
  %c1_i64_0 = hw.constant 1 : i64
  %9 = comb.icmp eq %addr, %c1_i64_0 : i64
  %10 = comb.mux %9, %mem_0_1, %mem_0_0 : i8
  %c2_i64_1 = hw.constant 2 : i64
  %11 = comb.icmp eq %addr, %c2_i64_1 : i64
  %12 = comb.mux %11, %mem_0_2, %10 : i8
  %c3_i64_2 = hw.constant 3 : i64
  %13 = comb.icmp eq %addr, %c3_i64_2 : i64
  %14 = comb.mux %13, %mem_0_3, %12 : i8
  hw.output %14 : i8
}
