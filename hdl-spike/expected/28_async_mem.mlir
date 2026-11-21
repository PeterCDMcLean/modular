hw.module @AsyncMem(in %addr : i64, in %wdata : i8, in %we : i1, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i8 = hw.constant 0 : i8
  %c5_i8 = hw.constant 5 : i8
  %false = hw.constant false
  %mem_1_0 = seq.firreg %2 clock %clk reset async %rst, %c5_i8 preset 5 : i8
  %mem_1_1 = seq.firreg %5 clock %clk reset async %rst, %c5_i8 preset 5 : i8
  %mem_1_2 = seq.firreg %8 clock %clk reset async %rst, %c5_i8 preset 5 : i8
  %mem_1_3 = seq.firreg %11 clock %clk reset async %rst, %c5_i8 preset 5 : i8
  %c0_i64 = hw.constant 0 : i64
  %0 = comb.icmp eq %addr, %c0_i64 : i64
  %1 = comb.and %we, %0 : i1
  %2 = comb.mux %1, %wdata, %mem_1_0 : i8
  %c1_i64 = hw.constant 1 : i64
  %3 = comb.icmp eq %addr, %c1_i64 : i64
  %4 = comb.and %we, %3 : i1
  %5 = comb.mux %4, %wdata, %mem_1_1 : i8
  %c2_i64 = hw.constant 2 : i64
  %6 = comb.icmp eq %addr, %c2_i64 : i64
  %7 = comb.and %we, %6 : i1
  %8 = comb.mux %7, %wdata, %mem_1_2 : i8
  %c3_i64 = hw.constant 3 : i64
  %9 = comb.icmp eq %addr, %c3_i64 : i64
  %10 = comb.and %we, %9 : i1
  %11 = comb.mux %10, %wdata, %mem_1_3 : i8
  %c1_i64_0 = hw.constant 1 : i64
  %12 = comb.icmp eq %addr, %c1_i64_0 : i64
  %13 = comb.mux %12, %mem_1_1, %mem_1_0 : i8
  %c2_i64_1 = hw.constant 2 : i64
  %14 = comb.icmp eq %addr, %c2_i64_1 : i64
  %15 = comb.mux %14, %mem_1_2, %13 : i8
  %c3_i64_2 = hw.constant 3 : i64
  %16 = comb.icmp eq %addr, %c3_i64_2 : i64
  %17 = comb.mux %16, %mem_1_3, %15 : i8
  hw.output %17 : i8
}
