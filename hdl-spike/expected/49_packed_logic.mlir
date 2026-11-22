hw.module @LogicPackedGet(in %p : i32, in %p_xz : i32, in %i : i64, out out : i8, out out_xz : i8) {
  %0 = comb.extract %i from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %1 = comb.mul %0, %c8_i32 : i32
  %2 = comb.shru %p, %1 : i32
  %3 = comb.extract %2 from 0 : (i32) -> i8
  %4 = comb.shru %p_xz, %1 : i32
  %5 = comb.extract %4 from 0 : (i32) -> i8
  hw.output %3, %5 : i8, i8
}
hw.module @LogicPackedPass(in %p : i32, in %p_xz : i32, in %i : i64, in %v : i8, in %v_xz : i8, out out : i32, out out_xz : i32) {
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
  %6 = comb.and %p, %5 : i32
  %7 = comb.or %6, %4 : i32
  %c0_i24_0 = hw.constant 0 : i24
  %8 = comb.concat %c0_i24_0, %v_xz : i24, i8
  %9 = comb.shl %8, %1 : i32
  %c-1_i32_1 = hw.constant -1 : i32
  %10 = comb.xor %2, %c-1_i32_1 : i32
  %11 = comb.and %p_xz, %10 : i32
  %12 = comb.or %11, %9 : i32
  hw.output %7, %12 : i32, i32
}
hw.module @LogicPackedReg(in %din : i32, in %din_xz : i32, in %clk : !seq.clock, in %rst : i1, out out : i32, out out_xz : i32) {
  %c0_i32 = hw.constant 0 : i32
  %c0_i32_0 = hw.constant 0 : i32
  %0 = seq.initial() {
    %c0_i32_3 = hw.constant 0 : i32
    seq.yield %c0_i32_3 : i32
  } : () -> !seq.immutable<i32>
  %1 = seq.compreg %din, %clk reset %rst, %c0_i32_0 initial %0 : i32  
  %c0_i32_1 = hw.constant 0 : i32
  %c0_i32_2 = hw.constant 0 : i32
  %2 = seq.initial() {
    %c0_i32_3 = hw.constant 0 : i32
    seq.yield %c0_i32_3 : i32
  } : () -> !seq.immutable<i32>
  %3 = seq.compreg %din_xz, %clk reset %rst, %c0_i32_2 initial %2 : i32  
  hw.output %1, %3 : i32, i32
}
