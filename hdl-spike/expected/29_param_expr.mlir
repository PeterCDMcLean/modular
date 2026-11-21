hw.module @DivMod_9(in %clk : !seq.clock, in %rst : i1, out out : i9) {
  %c1_i4 = hw.constant 1 : i4
  %c0_i4 = hw.constant 0 : i4
  %c2_i4 = hw.constant 2 : i4
  %0 = seq.initial() {
    %c2_i4_0 = hw.constant 2 : i4
    seq.yield %c2_i4_0 : i4
  } : () -> !seq.immutable<i4>
  %1 = seq.compreg %2, %clk reset %rst, %c2_i4 initial %0 : i4  
  %2 = comb.add %1, %c1_i4 : i4
  %c0_i9 = hw.constant 0 : i9
  hw.output %c0_i9 : i9
}
hw.module @SubMod_8(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i7 = hw.constant 1 : i7
  %c0_i7 = hw.constant 0 : i7
  %c1_i7_0 = hw.constant 1 : i7
  %0 = seq.initial() {
    %c1_i7_1 = hw.constant 1 : i7
    seq.yield %c1_i7_1 : i7
  } : () -> !seq.immutable<i7>
  %1 = seq.compreg %2, %clk reset %rst, %c1_i7_0 initial %0 : i7  
  %2 = comb.add %1, %c1_i7 : i7
  %c0_i8 = hw.constant 0 : i8
  hw.output %c0_i8 : i8
}
hw.module @MaxMod_8_2(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c3_i8 = hw.constant 3 : i8
  %0 = seq.initial() {
    %c3_i8_1 = hw.constant 3 : i8
    seq.yield %c3_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c3_i8 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  %c0_i8_0 = hw.constant 0 : i8
  hw.output %c0_i8_0 : i8
}
hw.module @ExprTop(in %clk_run_s : !seq.clock, in %rst_run_s : i1, in %clk_run_d : !seq.clock, in %rst_run_d : i1, in %clk_run_m : !seq.clock, in %rst_run_m : i1, out run_s_out : i8, out run_d_out : i9, out run_m_out : i8) {
  %s.out = hw.instance "s" @SubMod_8(clk: %clk_run_s: !seq.clock, rst: %rst_run_s: i1) -> (out: i8)
  %d.out = hw.instance "d" @DivMod_9(clk: %clk_run_d: !seq.clock, rst: %rst_run_d: i1) -> (out: i9)
  %m.out = hw.instance "m" @MaxMod_8_2(clk: %clk_run_m: !seq.clock, rst: %rst_run_m: i1) -> (out: i8)
  hw.output %s.out, %d.out, %m.out : i8, i9, i8
}
