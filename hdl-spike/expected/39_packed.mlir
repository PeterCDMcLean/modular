hw.module @PackedConstOut(out out : i32) {
  %c67305985_i32 = hw.constant 67305985 : i32
  hw.output %c67305985_i32 : i32
}
hw.module @PackedHold(in %din : i32, in %clk : !seq.clock, in %rst : i1, out out : i32) {
  %c0_i32 = hw.constant 0 : i32
  %c0_i32_0 = hw.constant 0 : i32
  %0 = seq.initial() {
    %c0_i32_1 = hw.constant 0 : i32
    seq.yield %c0_i32_1 : i32
  } : () -> !seq.immutable<i32>
  %1 = seq.compreg %din, %clk reset %rst, %c0_i32_0 initial %0 : i32  
  hw.output %1 : i32
}
hw.module @PackedPass(in %din : i32, out out : i32) {
  hw.output %din : i32
}
