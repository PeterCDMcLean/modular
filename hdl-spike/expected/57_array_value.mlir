hw.module @ArrayElem(in %a : i32, in %i : i64, out out : i8) {
  %0 = comb.extract %i from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %1 = comb.mul %0, %c8_i32 : i32
  %2 = comb.shru %a, %1 : i32
  %3 = comb.extract %2 from 0 : (i32) -> i8
  hw.output %3 : i8
}
hw.module @ArrayField(in %i : i64, in %v : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i32 = hw.constant 0 : i32
  %c67305985_i32 = hw.constant 67305985 : i32
  %0 = seq.initial() {
    %c67305985_i32_1 = hw.constant 67305985 : i32
    seq.yield %c67305985_i32_1 : i32
  } : () -> !seq.immutable<i32>
  %1 = seq.compreg %9, %clk reset %rst, %c67305985_i32 initial %0 : i32  
  %2 = comb.extract %i from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %3 = comb.mul %2, %c8_i32 : i32
  %c255_i32 = hw.constant 255 : i32
  %4 = comb.shl %c255_i32, %3 : i32
  %c0_i24 = hw.constant 0 : i24
  %5 = comb.concat %c0_i24, %v : i24, i8
  %6 = comb.shl %5, %3 : i32
  %c-1_i32 = hw.constant -1 : i32
  %7 = comb.xor %4, %c-1_i32 : i32
  %8 = comb.and %1, %7 : i32
  %9 = comb.or %8, %6 : i32
  %c0_i64 = hw.constant 0 : i64
  %10 = comb.extract %c0_i64 from 0 : (i64) -> i32
  %c8_i32_0 = hw.constant 8 : i32
  %11 = comb.mul %10, %c8_i32_0 : i32
  %12 = comb.shru %1, %11 : i32
  %13 = comb.extract %12 from 0 : (i32) -> i8
  hw.output %13 : i8
}
hw.module @ArrayPass(in %a : i32, out out : i32) {
  hw.output %a : i32
}
hw.module @ArrayReg(in %a : i32, in %clk : !seq.clock, in %rst : i1, out out : i32) {
  %c0_i32 = hw.constant 0 : i32
  %c0_i32_0 = hw.constant 0 : i32
  %0 = seq.initial() {
    %c0_i32_1 = hw.constant 0 : i32
    seq.yield %c0_i32_1 : i32
  } : () -> !seq.immutable<i32>
  %1 = seq.compreg %a, %clk reset %rst, %c0_i32_0 initial %0 : i32  
  hw.output %1 : i32
}
hw.module @ArrayUpdate(in %a : i32, in %i : i64, in %v : i8, out out : i32) {
  %0 = comb.extract %i from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %1 = comb.mul %0, %c8_i32 : i32
  %c255_i32 = hw.constant 255 : i32
  %2 = comb.shl %c255_i32, %1 : i32
  %c0_i24 = hw.constant 0 : i24
  %3 = comb.concat %c0_i24, %v : i24, i8
  %4 = comb.shl %3, %1 : i32
  %c-1_i32 = hw.constant -1 : i32
  %5 = comb.xor %2, %c-1_i32 : i32
  %6 = comb.and %a, %5 : i32
  %7 = comb.or %6, %4 : i32
  hw.output %7 : i32
}
hw.module @LogicArrayField(in %v : i8, in %v_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c1_i64 = hw.constant 1 : i64
  %c0_i32 = hw.constant 0 : i32
  %c0_i32_0 = hw.constant 0 : i32
  %0 = seq.initial() {
    %c0_i32_7 = hw.constant 0 : i32
    seq.yield %c0_i32_7 : i32
  } : () -> !seq.immutable<i32>
  %1 = seq.compreg %11, %clk reset %rst, %c0_i32_0 initial %0 : i32  
  %c0_i32_1 = hw.constant 0 : i32
  %c0_i32_2 = hw.constant 0 : i32
  %2 = seq.initial() {
    %c0_i32_7 = hw.constant 0 : i32
    seq.yield %c0_i32_7 : i32
  } : () -> !seq.immutable<i32>
  %3 = seq.compreg %16, %clk reset %rst, %c0_i32_2 initial %2 : i32  
  %4 = comb.extract %c1_i64 from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %5 = comb.mul %4, %c8_i32 : i32
  %c255_i32 = hw.constant 255 : i32
  %6 = comb.shl %c255_i32, %5 : i32
  %c0_i24 = hw.constant 0 : i24
  %7 = comb.concat %c0_i24, %v : i24, i8
  %8 = comb.shl %7, %5 : i32
  %c-1_i32 = hw.constant -1 : i32
  %9 = comb.xor %6, %c-1_i32 : i32
  %10 = comb.and %1, %9 : i32
  %11 = comb.or %10, %8 : i32
  %c0_i24_3 = hw.constant 0 : i24
  %12 = comb.concat %c0_i24_3, %v_xz : i24, i8
  %13 = comb.shl %12, %5 : i32
  %c-1_i32_4 = hw.constant -1 : i32
  %14 = comb.xor %6, %c-1_i32_4 : i32
  %15 = comb.and %3, %14 : i32
  %16 = comb.or %15, %13 : i32
  %c2_i64 = hw.constant 2 : i64
  %17 = comb.extract %c2_i64 from 0 : (i64) -> i32
  %c8_i32_5 = hw.constant 8 : i32
  %18 = comb.mul %17, %c8_i32_5 : i32
  %19 = comb.shru %1, %18 : i32
  %20 = comb.extract %19 from 0 : (i32) -> i8
  %21 = comb.extract %c2_i64 from 0 : (i64) -> i32
  %c8_i32_6 = hw.constant 8 : i32
  %22 = comb.mul %21, %c8_i32_6 : i32
  %23 = comb.shru %3, %22 : i32
  %24 = comb.extract %23 from 0 : (i32) -> i8
  hw.output %20, %24 : i8, i8
}
hw.module @LogicArrayPass(in %a : i32, in %a_xz : i32, out out : i32, out out_xz : i32) {
  hw.output %a, %a_xz : i32, i32
}
