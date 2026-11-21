hw.module @RamDemo(in %addr : i64, in %wd : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %0 = comb.extract %addr from 0 : (i64) -> i2
  %ram_0 = seq.hlmem @ram_0 %clk, %rst : <4xi8>
  %true = hw.constant true
  seq.write %ram_0[%0] %wd wren %we {latency = 1 : i64} : !seq.hlmem<4xi8>
  %1 = comb.extract %addr from 0 : (i64) -> i2
  %ram_0_rdata = seq.read %ram_0[%1] rden %true {latency = 0 : i64} : !seq.hlmem<4xi8>
  hw.output %ram_0_rdata : i8
}
