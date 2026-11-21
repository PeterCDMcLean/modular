hw.module @PowerOnCounter(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %0 = seq.initial() {
    %c9_i8 = hw.constant 9 : i8
    seq.yield %c9_i8 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %2, %clk reset %rst, %c5_i8 initial %0 : i8  
  %2 = comb.add %1, %c1_i8 : i8
  hw.output %1 : i8
}
