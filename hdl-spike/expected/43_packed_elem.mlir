hw.module @PackedGet(in %p : i32, in %i : i64, out out : i8) {
  %0 = comb.extract %i from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %1 = comb.mul %0, %c8_i32 : i32
  %2 = comb.shru %p, %1 : i32
  %3 = comb.extract %2 from 0 : (i32) -> i8
  hw.output %3 : i8
}
hw.module @PackedSet(in %p : i32, in %i : i64, in %v : i8, out out : i32) {
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
  hw.output %7 : i32
}
