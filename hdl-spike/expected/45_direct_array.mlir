hw.module @DirectArraySet(in %i : i64, in %v : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %v, %clk, %2 reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %v, %clk, %3 reset %rst, %c0_i8_1 initial %1 : i8  
  %c0_i64 = hw.constant 0 : i64
  %2 = comb.icmp eq %i, %c0_i64 : i64
  %c1_i64 = hw.constant 1 : i64
  %3 = comb.icmp eq %i, %c1_i64 : i64
  %c1_i64_2 = hw.constant 1 : i64
  %4 = comb.icmp eq %i, %c1_i64_2 : i64
  %5 = comb.mux %4, %mem_0_1, %mem_0_0 : i8
  hw.output %5 : i8
}
hw.module @DirectLogicSet(in %i : i64, in %v : i8, in %v_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %v, %clk, %4 reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0_xz = seq.compreg.ce sym @mem_0_0_xz %v_xz, %clk, %4 reset %rst, %c0_i8_1 initial %1 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %v, %clk, %5 reset %rst, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_5 = hw.constant 0 : i8
    seq.yield %c0_i8_5 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1_xz = seq.compreg.ce sym @mem_0_1_xz %v_xz, %clk, %5 reset %rst, %c0_i8_3 initial %3 : i8  
  %c0_i64 = hw.constant 0 : i64
  %4 = comb.icmp eq %i, %c0_i64 : i64
  %c1_i64 = hw.constant 1 : i64
  %5 = comb.icmp eq %i, %c1_i64 : i64
  %c1_i64_4 = hw.constant 1 : i64
  %6 = comb.icmp eq %i, %c1_i64_4 : i64
  %7 = comb.mux %6, %mem_0_1, %mem_0_0 : i8
  %8 = comb.mux %6, %mem_0_1_xz, %mem_0_0_xz : i8
  hw.output %7, %8 : i8, i8
}
hw.module @DirectStaticSet(in %v : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %v, %clk, %true reset %rst, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_3 = hw.constant 0 : i8
    seq.yield %c0_i8_3 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %mem_0_1, %clk, %false reset %rst, %c0_i8_1 initial %1 : i8  
  %true = hw.constant true
  %c0_i64_2 = hw.constant 0 : i64
  hw.output %mem_0_0 : i8
}
