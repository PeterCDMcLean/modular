hw.module @Inv(in %a : i1, out y : i1) {
  %true = hw.constant true
  %0 = comb.xor %a, %true : i1
  hw.output %0 : i1
}
