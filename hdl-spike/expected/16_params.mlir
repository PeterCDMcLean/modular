hw.module @ParamCounter<W: i32 = 8>(in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.decl.ref<"W">>) {
  %W = sv.verbatim.expr "W'(1)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %W_0 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %W_1 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %0 = seq.compreg %1, %clk reset %rst, %W_1 : !hw.int<#hw.param.decl.ref<"W">>  
  %1 = comb.add %0, %W : !hw.int<#hw.param.decl.ref<"W">>
  hw.output %0 : !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @TwoWidths(in %clk_run_narrow : !seq.clock, in %rst_run_narrow : i1, in %clk_run_wide : !seq.clock, in %rst_run_wide : i1, out run_narrow_out : i8, out run_wide_out : i16) {
  %narrow.out = hw.instance "narrow" @ParamCounter<W: i32 = 8>(clk: %clk_run_narrow: !seq.clock, rst: %rst_run_narrow: i1) -> (out: i8)
  %wide.out = hw.instance "wide" @ParamCounter<W: i32 = 16>(clk: %clk_run_wide: !seq.clock, rst: %rst_run_wide: i1) -> (out: i16)
  hw.output %narrow.out, %wide.out : i8, i16
}
