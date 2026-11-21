hw.module @Add8(in %a : i8, in %b : i8, out y : i8) {
  %0 = comb.add %a, %b : i8
  hw.output %0 : i8
}
