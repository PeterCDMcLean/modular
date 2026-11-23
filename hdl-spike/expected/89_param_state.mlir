hw.module @ParamAccumulator<W: i32 = 8>(in %step : !hw.int<#hw.param.decl.ref<"W">>, in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.decl.ref<"W">>) {
  %W = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %W_0 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %0 = seq.compreg %1, %clk reset %rst, %W_0 : !hw.int<#hw.param.decl.ref<"W">>  
  %1 = comb.add %0, %step : !hw.int<#hw.param.decl.ref<"W">>
  %W_1 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %W_2 = sv.verbatim.expr "W'(1)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %2 = seq.compreg %3, %clk reset %rst, %W_2 : !hw.int<#hw.param.decl.ref<"W">>  
  %W_3 = sv.verbatim.expr "W'(1)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %3 = comb.add %2, %W_3 : !hw.int<#hw.param.decl.ref<"W">>
  %4 = comb.xor %0, %2 : !hw.int<#hw.param.decl.ref<"W">>
  hw.output %4 : !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @ParamStateUsers(in %n : i8, in %w : i16, in %clk_run_narrow : !seq.clock, in %rst_run_narrow : i1, in %clk_run_wide : !seq.clock, in %rst_run_wide : i1, out run_narrow_out : i8, out run_wide_out : i16) {
  %narrow.out = hw.instance "narrow" @ParamAccumulator<W: i32 = 8>(step: %n: i8, clk: %clk_run_narrow: !seq.clock, rst: %rst_run_narrow: i1) -> (out: i8)
  %wide.out = hw.instance "wide" @ParamAccumulator<W: i32 = 16>(step: %w: i16, clk: %clk_run_wide: !seq.clock, rst: %rst_run_wide: i1) -> (out: i16)
  hw.output %narrow.out, %wide.out : i8, i16
}
