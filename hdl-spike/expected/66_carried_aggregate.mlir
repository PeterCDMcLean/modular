hw.module @RuntimeArrayCarry(in %count : i64, in %wd : i8, in %clk : !seq.clock, in %rst : i1, out out : i8) {
  %c0_i32 = hw.constant 0 : i32
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_13 = hw.constant 0 : i64
    seq.yield %c0_i64_13 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %21, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %25, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i32_2 = hw.constant 0 : i32
  %c0_i32_3 = hw.constant 0 : i32
  %4 = seq.initial() {
    %c0_i32_13 = hw.constant 0 : i32
    seq.yield %c0_i32_13 : i32
  } : () -> !seq.immutable<i32>
  %5 = seq.compreg %17, %clk reset %rst, %c0_i32_3 initial %4 : i32  
  %6 = comb.icmp ult %1, %count : i64
  %7 = comb.and %3, %6 : i1
  %8 = comb.extract %1 from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %9 = comb.mul %8, %c8_i32 : i32
  %c255_i32 = hw.constant 255 : i32
  %10 = comb.shl %c255_i32, %9 : i32
  %c0_i24 = hw.constant 0 : i24
  %11 = comb.concat %c0_i24, %wd : i24, i8
  %12 = comb.shl %11, %9 : i32
  %c-1_i32 = hw.constant -1 : i32
  %13 = comb.xor %10, %c-1_i32 : i32
  %14 = comb.and %5, %13 : i32
  %15 = comb.or %14, %12 : i32
  %16 = comb.mux %7, %15, %5 : i32
  %17 = comb.mux %3, %16, %c0_i32 : i32
  %c1_i64 = hw.constant 1 : i64
  %18 = comb.add %1, %c1_i64 : i64
  %c0_i64_4 = hw.constant 0 : i64
  %19 = comb.icmp eq %18, %count : i64
  %20 = comb.and %7, %19 : i1
  %21 = comb.mux %7, %18, %c0_i64_4 : i64
  %false_5 = hw.constant false
  %false_6 = hw.constant false
  %22 = seq.initial() {
    %false_13 = hw.constant false
    seq.yield %false_13 : i1
  } : () -> !seq.immutable<i1>
  %23 = seq.compreg %20, %clk reset %rst, %false_6 initial %22 : i1  
  %true = hw.constant true
  %24 = comb.xor %20, %true : i1
  %true_7 = hw.constant true
  %25 = comb.mux %3, %24, %true_7 : i1
  %c0_i64_8 = hw.constant 0 : i64
  %26 = comb.extract %c0_i64_8 from 0 : (i64) -> i32
  %c8_i32_9 = hw.constant 8 : i32
  %27 = comb.mul %26, %c8_i32_9 : i32
  %28 = comb.shru %5, %27 : i32
  %29 = comb.extract %28 from 0 : (i32) -> i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_10 = hw.constant 0 : i8
  %30 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_0 = seq.compreg.ce sym @reg_0 %29, %clk, %23 reset %rst, %c0_i8_10 initial %30 : i8  
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_11 = hw.constant 0 : i8
  %c0_i8_12 = hw.constant 0 : i8
  %31 = seq.initial() {
    %c0_i8_13 = hw.constant 0 : i8
    seq.yield %c0_i8_13 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %32, %clk, %23 reset %rst, %c0_i8_12 initial %31 : i8  
  %32 = comb.add %reg_1, %c1_i8 : i8
  hw.output %reg_0 : i8
}
hw.module @RuntimeLogicArrayCarry(in %count : i64, in %init : i32, in %init_xz : i32, in %wd : i8, in %wd_xz : i8, in %clk : !seq.clock, in %rst : i1, out out : i8, out out_xz : i8) {
  %c0_i64 = hw.constant 0 : i64
  %c0_i64_0 = hw.constant 0 : i64
  %0 = seq.initial() {
    %c0_i64_19 = hw.constant 0 : i64
    seq.yield %c0_i64_19 : i64
  } : () -> !seq.immutable<i64>
  %1 = seq.compreg %30, %clk reset %rst, %c0_i64_0 initial %0 : i64  
  %false = hw.constant false
  %false_1 = hw.constant false
  %2 = seq.initial() {
    %false_19 = hw.constant false
    seq.yield %false_19 : i1
  } : () -> !seq.immutable<i1>
  %3 = seq.compreg %34, %clk reset %rst, %false_1 initial %2 : i1  
  %c0_i32 = hw.constant 0 : i32
  %c0_i32_2 = hw.constant 0 : i32
  %4 = seq.initial() {
    %c0_i32_19 = hw.constant 0 : i32
    seq.yield %c0_i32_19 : i32
  } : () -> !seq.immutable<i32>
  %5 = seq.compreg %25, %clk reset %rst, %c0_i32_2 initial %4 : i32  
  %c0_i32_3 = hw.constant 0 : i32
  %c0_i32_4 = hw.constant 0 : i32
  %6 = seq.initial() {
    %c0_i32_19 = hw.constant 0 : i32
    seq.yield %c0_i32_19 : i32
  } : () -> !seq.immutable<i32>
  %7 = seq.compreg %26, %clk reset %rst, %c0_i32_4 initial %6 : i32  
  %8 = comb.icmp ult %1, %count : i64
  %9 = comb.and %3, %8 : i1
  %10 = comb.extract %1 from 0 : (i64) -> i32
  %c8_i32 = hw.constant 8 : i32
  %11 = comb.mul %10, %c8_i32 : i32
  %c255_i32 = hw.constant 255 : i32
  %12 = comb.shl %c255_i32, %11 : i32
  %c0_i24 = hw.constant 0 : i24
  %13 = comb.concat %c0_i24, %wd : i24, i8
  %14 = comb.shl %13, %11 : i32
  %c-1_i32 = hw.constant -1 : i32
  %15 = comb.xor %12, %c-1_i32 : i32
  %16 = comb.and %5, %15 : i32
  %17 = comb.or %16, %14 : i32
  %c0_i24_5 = hw.constant 0 : i24
  %18 = comb.concat %c0_i24_5, %wd_xz : i24, i8
  %19 = comb.shl %18, %11 : i32
  %c-1_i32_6 = hw.constant -1 : i32
  %20 = comb.xor %12, %c-1_i32_6 : i32
  %21 = comb.and %7, %20 : i32
  %22 = comb.or %21, %19 : i32
  %23 = comb.mux %9, %17, %5 : i32
  %24 = comb.mux %9, %22, %7 : i32
  %25 = comb.mux %3, %23, %init : i32
  %26 = comb.mux %3, %24, %init_xz : i32
  %c1_i64 = hw.constant 1 : i64
  %27 = comb.add %1, %c1_i64 : i64
  %c0_i64_7 = hw.constant 0 : i64
  %28 = comb.icmp eq %27, %count : i64
  %29 = comb.and %9, %28 : i1
  %30 = comb.mux %9, %27, %c0_i64_7 : i64
  %false_8 = hw.constant false
  %false_9 = hw.constant false
  %31 = seq.initial() {
    %false_19 = hw.constant false
    seq.yield %false_19 : i1
  } : () -> !seq.immutable<i1>
  %32 = seq.compreg %29, %clk reset %rst, %false_9 initial %31 : i1  
  %true = hw.constant true
  %33 = comb.xor %29, %true : i1
  %true_10 = hw.constant true
  %34 = comb.mux %3, %33, %true_10 : i1
  %c0_i64_11 = hw.constant 0 : i64
  %35 = comb.extract %c0_i64_11 from 0 : (i64) -> i32
  %c8_i32_12 = hw.constant 8 : i32
  %36 = comb.mul %35, %c8_i32_12 : i32
  %37 = comb.shru %5, %36 : i32
  %38 = comb.extract %37 from 0 : (i32) -> i8
  %39 = comb.extract %c0_i64_11 from 0 : (i64) -> i32
  %c8_i32_13 = hw.constant 8 : i32
  %40 = comb.mul %39, %c8_i32_13 : i32
  %41 = comb.shru %7, %40 : i32
  %42 = comb.extract %41 from 0 : (i32) -> i8
  %c0_i8 = hw.constant 0 : i8
  %c0_i8_14 = hw.constant 0 : i8
  %43 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %44 = seq.compreg %47, %clk reset %rst, %c0_i8_14 initial %43 : i8  
  %c0_i8_15 = hw.constant 0 : i8
  %c0_i8_16 = hw.constant 0 : i8
  %45 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %46 = seq.compreg %48, %clk reset %rst, %c0_i8_16 initial %45 : i8  
  %47 = comb.mux %32, %38, %44 : i8
  %48 = comb.mux %32, %42, %46 : i8
  %c1_i8 = hw.constant 1 : i8
  %c0_i8_17 = hw.constant 0 : i8
  %c0_i8_18 = hw.constant 0 : i8
  %49 = seq.initial() {
    %c0_i8_19 = hw.constant 0 : i8
    seq.yield %c0_i8_19 : i8
  } : () -> !seq.immutable<i8>
  %reg_1 = seq.compreg.ce sym @reg_1 %50, %clk, %32 reset %rst, %c0_i8_18 initial %49 : i8  
  %50 = comb.add %reg_1, %c1_i8 : i8
  hw.output %44, %46 : i8, i8
}
