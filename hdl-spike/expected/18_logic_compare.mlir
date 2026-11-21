hw.module @LogicCompare(in %a : i8, in %a_xz : i8, in %b : i8, in %b_xz : i8, in %x : i8, in %x_xz : i8, in %y : i8, in %y_xz : i8, out eq_out : i1, out eq_out_xz : i1, out ne_out : i1, out ne_out_xz : i1) {
  %0 = comb.or %a_xz, %b_xz : i8
  %c-1_i8 = hw.constant -1 : i8
  %1 = comb.xor %0, %c-1_i8 : i8
  %2 = comb.xor %a, %b : i8
  %3 = comb.and %1, %2 : i8
  %c0_i8 = hw.constant 0 : i8
  %4 = comb.icmp ne %3, %c0_i8 : i8
  %5 = comb.icmp ne %0, %c0_i8 : i8
  %true = hw.constant true
  %6 = comb.xor %4, %true : i1
  %7 = comb.and %5, %6 : i1
  %true_0 = hw.constant true
  %8 = comb.xor %5, %true_0 : i1
  %9 = comb.and %6, %8 : i1
  %10 = comb.or %x_xz, %y_xz : i8
  %c-1_i8_1 = hw.constant -1 : i8
  %11 = comb.xor %10, %c-1_i8_1 : i8
  %12 = comb.xor %x, %y : i8
  %13 = comb.and %11, %12 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %14 = comb.icmp ne %13, %c0_i8_2 : i8
  %15 = comb.icmp ne %10, %c0_i8_2 : i8
  %true_3 = hw.constant true
  %16 = comb.xor %14, %true_3 : i1
  %17 = comb.and %15, %16 : i1
  hw.output %9, %7, %14, %17 : i1, i1, i1, i1
}
