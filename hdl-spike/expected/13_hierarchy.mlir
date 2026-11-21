hw.module @Inverter(in %a : i8, out out : i8) {
  %c-1_i8 = hw.constant -1 : i8
  %0 = comb.xor %a, %c-1_i8 : i8
  hw.output %0 : i8
}
hw.module @Top(in %a : i8, out out : i8) {
  %inv.out = hw.instance "inv" @Inverter(a: %a: i8) -> (out: i8)
  hw.output %inv.out : i8
}
