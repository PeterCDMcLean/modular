hw.module @LogicOps(in %c : i1, in %c_xz : i1, in %a : i8, in %a_xz : i8, in %b : i8, in %b_xz : i8, out out : i8, out out_xz : i8) {
  %0 = comb.or %a_xz, %b_xz : i8
  %1 = comb.or %a_xz, %a : i8
  %2 = comb.or %b_xz, %b : i8
  %3 = comb.and %0, %1 : i8
  %4 = comb.and %3, %2 : i8
  %5 = comb.and %a, %b : i8
  %6 = comb.xor %a, %b : i8
  %7 = comb.or %a_xz, %b_xz : i8
  %8 = comb.or %4, %7 : i8
  %c-1_i8 = hw.constant -1 : i8
  %9 = comb.xor %5, %c-1_i8 : i8
  %10 = comb.or %4, %9 : i8
  %c-1_i8_0 = hw.constant -1 : i8
  %11 = comb.xor %6, %c-1_i8_0 : i8
  %12 = comb.or %7, %11 : i8
  %13 = comb.and %8, %10 : i8
  %14 = comb.and %13, %12 : i8
  %15 = comb.or %5, %6 : i8
  %c-1_i8_1 = hw.constant -1 : i8
  %16 = comb.xor %15, %c-1_i8_1 : i8
  %17 = comb.mux %c, %16, %a : i8
  %18 = comb.mux %c, %14, %a_xz : i8
  %19 = comb.or %14, %a_xz : i8
  %c-1_i8_2 = hw.constant -1 : i8
  %20 = comb.xor %19, %c-1_i8_2 : i8
  %21 = comb.xor %16, %a : i8
  %c-1_i8_3 = hw.constant -1 : i8
  %22 = comb.xor %21, %c-1_i8_3 : i8
  %23 = comb.and %20, %22 : i8
  %c-1_i8_4 = hw.constant -1 : i8
  %24 = comb.xor %23, %c-1_i8_4 : i8
  %25 = comb.mux %c_xz, %24, %18 : i8
  hw.output %17, %25 : i8, i8
}
