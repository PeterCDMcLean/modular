hw.module @TwoIndependentMems(in %wd_a : i8, in %en_a : i1, in %wd_b : i8, in %en_b : i1, in %clk_run_a : !seq.clock, in %rst_run_a : i1, in %clk_run_b : !seq.clock, in %rst_run_b : i1, out run_a_out : i8, out run_b_out : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i8 = hw.constant 0 : i8
  %false = hw.constant false
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_0 = seq.compreg.ce sym @mem_0_0 %wd_a, %clk_run_a, %en_a reset %rst_run_a, %c0_i8_0 initial %0 : i8  
  %c0_i8_1 = hw.constant 0 : i8
  %1 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_1 = seq.compreg.ce sym @mem_0_1 %mem_0_1, %clk_run_a, %false reset %rst_run_a, %c0_i8_1 initial %1 : i8  
  %c0_i8_2 = hw.constant 0 : i8
  %2 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_2 = seq.compreg.ce sym @mem_0_2 %mem_0_2, %clk_run_a, %false reset %rst_run_a, %c0_i8_2 initial %2 : i8  
  %c0_i8_3 = hw.constant 0 : i8
  %3 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_0_3 = seq.compreg.ce sym @mem_0_3 %mem_0_3, %clk_run_a, %false reset %rst_run_a, %c0_i8_3 initial %3 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_4 = hw.constant 0 : i8
  %c0_i8_5 = hw.constant 0 : i8
  %4 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %5 = seq.compreg %6, %clk_run_a reset %rst_run_a, %c0_i8_5 initial %4 : i8  
  %6 = comb.add %5, %c1_i8 : i8
  %c0_i64_6 = hw.constant 0 : i64
  %7 = comb.xor %mem_0_0, %5 : i8
  %c0_i64_7 = hw.constant 0 : i64
  %c0_i8_8 = hw.constant 0 : i8
  %false_9 = hw.constant false
  %c0_i8_10 = hw.constant 0 : i8
  %8 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_1_0 = seq.compreg.ce sym @mem_1_0 %wd_b, %clk_run_b, %en_b reset %rst_run_b, %c0_i8_10 initial %8 : i8  
  %c0_i8_11 = hw.constant 0 : i8
  %9 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_1_1 = seq.compreg.ce sym @mem_1_1 %mem_1_1, %clk_run_b, %false_9 reset %rst_run_b, %c0_i8_11 initial %9 : i8  
  %c0_i8_12 = hw.constant 0 : i8
  %10 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_1_2 = seq.compreg.ce sym @mem_1_2 %mem_1_2, %clk_run_b, %false_9 reset %rst_run_b, %c0_i8_12 initial %10 : i8  
  %c0_i8_13 = hw.constant 0 : i8
  %11 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %mem_1_3 = seq.compreg.ce sym @mem_1_3 %mem_1_3, %clk_run_b, %false_9 reset %rst_run_b, %c0_i8_13 initial %11 : i8  
  %c2_i8 = hw.constant 2 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %c0_i8_15 = hw.constant 0 : i8
  %12 = seq.initial() {
    %c0_i8_17 = hw.constant 0 : i8
    seq.yield %c0_i8_17 : i8
  } : () -> !seq.immutable<i8>
  %13 = seq.compreg %14, %clk_run_b reset %rst_run_b, %c0_i8_15 initial %12 : i8  
  %14 = comb.add %13, %c2_i8 : i8
  %c0_i64_16 = hw.constant 0 : i64
  %15 = comb.xor %mem_1_0, %13 : i8
  hw.output %7, %15 : i8, i8
}
