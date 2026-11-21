hw.module @LogicInverter(in %a : i8, in %a_xz : i8, out out : i8, out out_xz : i8) {
  %c-1_i8 = hw.constant -1 : i8
  %0 = comb.xor %a, %c-1_i8 : i8
  hw.output %0, %a_xz : i8, i8
}
hw.module @LogicTop(in %d : i8, in %d_xz : i8, out out : i8, out out_xz : i8) {
  %inv.out, %inv.out_xz = hw.instance "inv" @LogicInverter(a: %d: i8, a_xz: %d_xz: i8) -> (out: i8, out_xz: i8)
  hw.output %inv.out, %inv.out_xz : i8, i8
}
