hw.module @ArrayRamInit(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %0 = comb.extract %addr from 0 : (i64) -> i2
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %1 = hw.array_create %c0_i8, %c0_i8_0, %c0_i8_1, %c0_i8_2 : i8
  %c1_i8 = hw.constant 1 : i8
  %c2_i8 = hw.constant 2 : i8
  %c3_i8 = hw.constant 3 : i8
  %c4_i8 = hw.constant 4 : i8
  %2 = hw.array_create %c1_i8, %c2_i8, %c3_i8, %c4_i8 : i8
  %array_ram_1 = seq.firreg %4 clock %clk reset sync %rst, %2 preset 151587081 : !hw.array<4xi8>
  %true = hw.constant true
  %3 = hw.array_inject %array_ram_1[%0], %wd : !hw.array<4xi8>, i2
  %4 = comb.mux %we, %3, %array_ram_1 : !hw.array<4xi8>
  %5 = comb.extract %addr from 0 : (i64) -> i2
  %6 = hw.array_get %array_ram_1[%5] : !hw.array<4xi8>, i2
  hw.output %6 : i8
}
hw.module @ArrayRamInitLow(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst_n : i1, out out : i8) {
  %0 = comb.extract %addr from 0 : (i64) -> i2
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_0 = hw.constant 0 : i8
  %c0_i8_1 = hw.constant 0 : i8
  %c0_i8_2 = hw.constant 0 : i8
  %1 = hw.array_create %c0_i8, %c0_i8_0, %c0_i8_1, %c0_i8_2 : i8
  %c1_i8 = hw.constant 1 : i8
  %c2_i8 = hw.constant 2 : i8
  %c3_i8 = hw.constant 3 : i8
  %c4_i8 = hw.constant 4 : i8
  %2 = hw.array_create %c1_i8, %c2_i8, %c3_i8, %c4_i8 : i8
  %true = hw.constant true
  %3 = comb.xor %rst_n, %true : i1
  %array_ram_1 = seq.firreg %5 clock %clk reset async %3, %2 preset 67305985 : !hw.array<4xi8>
  %true_3 = hw.constant true
  %4 = hw.array_inject %array_ram_1[%0], %wd : !hw.array<4xi8>, i2
  %5 = comb.mux %we, %4, %array_ram_1 : !hw.array<4xi8>
  %6 = comb.extract %addr from 0 : (i64) -> i2
  %7 = hw.array_get %array_ram_1[%6] : !hw.array<4xi8>, i2
  hw.output %7 : i8
}
hw.module @RamInit(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %0 = comb.extract %addr from 0 : (i64) -> i2
  %ram_1 = seq.hlmem @ram_1 %clk, %rst {hdl.poweron = [9 : i8, 9 : i8, 9 : i8, 9 : i8], hdl.reset = [1 : i8, 2 : i8, 3 : i8, 4 : i8]} : <4xi8>
  %true = hw.constant true
  seq.write %ram_1[%0] %wd wren %we {latency = 1 : i64} : !seq.hlmem<4xi8>
  %1 = comb.extract %addr from 0 : (i64) -> i2
  %ram_1_rdata = seq.read %ram_1[%1] rden %true {latency = 0 : i64} : !seq.hlmem<4xi8>
  hw.output %ram_1_rdata : i8
}
hw.module @RamInitAsync(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %0 = comb.extract %addr from 0 : (i64) -> i2
  %ram_1 = seq.hlmem @ram_1 %clk, %rst {hdl.poweron = [1 : i8, 2 : i8, 3 : i8, 4 : i8], hdl.reset = [1 : i8, 2 : i8, 3 : i8, 4 : i8], hdl.reset_async} : <4xi8>
  %true = hw.constant true
  seq.write %ram_1[%0] %wd wren %we {latency = 1 : i64} : !seq.hlmem<4xi8>
  %1 = comb.extract %addr from 0 : (i64) -> i2
  %ram_1_rdata = seq.read %ram_1[%1] rden %true {latency = 0 : i64} : !seq.hlmem<4xi8>
  hw.output %ram_1_rdata : i8
}
