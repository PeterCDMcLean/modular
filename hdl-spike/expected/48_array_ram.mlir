hw.module @ArrayRamDemo(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %0 = comb.extract %addr from 0 : (i64) -> i2
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %1 = hw.array_create %c0_i8, %c0_i8_0, %c0_i8_1, %c0_i8_2 : i8
  %array_ram_0 = seq.firreg %3 clock %clk : !hw.array<4xi8>
  %true = hw.constant true
  %2 = hw.array_inject %array_ram_0[%0], %wd : !hw.array<4xi8>, i2
  %3 = comb.mux %we, %2, %array_ram_0 : !hw.array<4xi8>
  %4 = comb.extract %addr from 0 : (i64) -> i2
  %5 = hw.array_get %array_ram_0[%4] : !hw.array<4xi8>, i2
  hw.output %5 : i8
}
