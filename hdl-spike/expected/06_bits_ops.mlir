hw.module @BitsOps(in %a : i12, in %b : i12, out out : i12) {
  %0 = comb.and %a, %b : i12
  %c-1_i12 = hw.constant -1 : i12
  %1 = comb.xor %a, %c-1_i12 : i12
  %2 = comb.xor %0, %1 : i12
  %3 = comb.sub %a, %b : i12
  %4 = comb.add %3, %b : i12
  %5 = comb.or %2, %4 : i12
  hw.output %5 : i12
}
