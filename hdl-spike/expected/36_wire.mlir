hw.module @WireDemo(in %a : i8, in %b : i8, out out : i8) {
  %0 = comb.xor %a, %b : i8
  hw.output %0 : i8
}
