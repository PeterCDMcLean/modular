hw.module @ParamCounter_16(in %clk : !seq.clock, in %rst : i1, out out : i16) {
  %c1_i16 = hw.constant 1 : i16
  %c0_i16 = hw.constant 0 : i16
  %c0_i16_0 = hw.constant 0 : i16
  %0 = seq.initial() {
    %c0_i16_1 = hw.constant 0 : i16
    seq.yield %c0_i16_1 : i16
  } : () -> !seq.immutable<i16>
  %1 = seq.compreg %2, %clk reset %rst, %c0_i16_0 initial %0 : i16  
  %2 = comb.add %1, %c1_i16 : i16
  hw.output %1 : i16
}
hw.module @ParamCounter_8(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c0_i8_0 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  hw.output %1 : i8
}
hw.module @TwoWidths(in %clk_run_narrow : !seq.clock, in %rst_run_narrow : i1, in %clk_run_wide : !seq.clock, in %rst_run_wide : i1, out run_narrow_out : i8, out run_wide_out : i16) {
  %narrow.out = hw.instance "narrow" @ParamCounter_8(clk: %clk_run_narrow: !seq.clock, rst: %rst_run_narrow: i1) -> (out: i8)
  %wide.out = hw.instance "wide" @ParamCounter_16(clk: %clk_run_wide: !seq.clock, rst: %rst_run_wide: i1) -> (out: i16)
  hw.output %narrow.out, %wide.out : i8, i16
}
