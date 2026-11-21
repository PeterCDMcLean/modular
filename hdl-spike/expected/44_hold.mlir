hw.module @PackedConstHold(in %clk : !seq.clock, in %rst : i1, out out : i32) {
  %c0_i32 = hw.constant 0 : i32
  %c67305985_i32 = hw.constant 67305985 : i32
  %0 = seq.initial() {
    %c67305985_i32_0 = hw.constant 67305985 : i32
    seq.yield %c67305985_i32_0 : i32
  } : () -> !seq.immutable<i32>
  %1 = seq.compreg %1, %clk reset %rst, %c67305985_i32 initial %0 : i32  
  hw.output %1 : i32
}
hw.module @UnwrittenBits(in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c7_i8 = hw.constant 7 : i8
  %0 = seq.initial() {
    %c7_i8_0 = hw.constant 7 : i8
    seq.yield %c7_i8_0 : i8
  } : () -> !seq.immutable<i8>
  %1 = seq.compreg %1, %clk reset %rst, %c7_i8 initial %0 : i8  
  hw.output %1 : i8
}
