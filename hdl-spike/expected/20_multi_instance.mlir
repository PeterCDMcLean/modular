hw.module @Counter(in %en : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c1_i8 = hw.constant 1 : i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %0 = seq.initial() {
    %c0_i8_1 = hw.constant 0 : i8
    seq.yield %c0_i8_1 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %1, %clk, %en reset %rst, %c0_i8_0 initial %0 : i8  
  %1 = comb.add %reg_0, %c1_i8 : i8
  hw.output %reg_0 : i8
}
hw.module @Inverter(in %a : i8, out out : i8) {
  %c-1_i8 = hw.constant -1 : i8
  %0 = comb.xor %a, %c-1_i8 : i8
  hw.output %0 : i8
}
hw.module @MultiInstance(in %a : i8, in %b : i8, in %en_a : i1, in %en_b : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %inv_a.out = hw.instance "inv_a" @Inverter(a: %a: i8) -> (out: i8)
  %inv_b.out = hw.instance "inv_b" @Inverter(a: %b: i8) -> (out: i8)
  %ctr_a.out = hw.instance "ctr_a" @Counter(en: %en_a: i1, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %ctr_b.out = hw.instance "ctr_b" @Counter(en: %en_b: i1, clk: %clk: !seq.clock, rst: %rst: i1) -> (out: i8)
  %0 = comb.xor %inv_a.out, %inv_b.out : i8
  %1 = comb.xor %0, %ctr_a.out : i8
  %2 = comb.xor %1, %ctr_b.out : i8
  hw.output %2 : i8
}
