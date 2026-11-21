hw.module @MemDepth2(in %addr : i64, in %wdata : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c7_i8 = hw.constant 7 : i8
  %0 = seq.initial() {
    %c7_i8_1 = hw.constant 7 : i8
    seq.yield %c7_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wdata, %clk, %3 reset %rst, %c7_i8 initial %0 : i8  
  %c9_i8 = hw.constant 9 : i8
  %1 = seq.initial() {
    %c9_i8_1 = hw.constant 9 : i8
    seq.yield %c9_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %wdata, %clk, %5 reset %rst, %c9_i8 initial %1 : i8  
  %c0_i64 = hw.constant 0 : i64
  %2 = comb.icmp eq %addr, %c0_i64 : i64
  %3 = comb.and %we, %2 : i1
  %c1_i64 = hw.constant 1 : i64
  %4 = comb.icmp eq %addr, %c1_i64 : i64
  %5 = comb.and %we, %4 : i1
  %c1_i64_0 = hw.constant 1 : i64
  %6 = comb.icmp eq %addr, %c1_i64_0 : i64
  %7 = comb.mux %6, %mem_0_1, %mem_0_0 : i8
  hw.output %7 : i8
}
