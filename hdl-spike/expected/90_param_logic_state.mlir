hw.module @ParamLogicState<W: i32 = 8>(in %d : !hw.int<#hw.param.decl.ref<"W">>, in %d_xz : !hw.int<#hw.param.decl.ref<"W">>, in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.decl.ref<"W">>, out out_xz : !hw.int<#hw.param.decl.ref<"W">>) {
  %W = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %W_0 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %0 = seq.compreg %8, %clk reset %rst, %W_0 : !hw.int<#hw.param.decl.ref<"W">>  
  %W_1 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %W_2 = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %1 = seq.compreg %6, %clk reset %rst, %W_2 : !hw.int<#hw.param.decl.ref<"W">>  
  %2 = comb.or %1, %d_xz : !hw.int<#hw.param.decl.ref<"W">>
  %3 = comb.or %1, %0 : !hw.int<#hw.param.decl.ref<"W">>
  %4 = comb.or %d_xz, %d : !hw.int<#hw.param.decl.ref<"W">>
  %5 = comb.and %2, %3 : !hw.int<#hw.param.decl.ref<"W">>
  %6 = comb.and %5, %4 : !hw.int<#hw.param.decl.ref<"W">>
  %7 = comb.and %0, %d : !hw.int<#hw.param.decl.ref<"W">>
  %W_3 = sv.verbatim.expr "W'(-1)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  %8 = comb.xor %7, %W_3 : !hw.int<#hw.param.decl.ref<"W">>
  hw.output %0, %1 : !hw.int<#hw.param.decl.ref<"W">>, !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @ParamLogicUsers(in %n : i8, in %n_xz : i8, in %w : i16, in %w_xz : i16, in %clk_run_narrow : !seq.clock, in %rst_run_narrow : i1, in %clk_run_wide : !seq.clock, in %rst_run_wide : i1, out run_narrow_out : i8, out run_narrow_out_xz : i8, out run_wide_out : i16, out run_wide_out_xz : i16) {
  %narrow.out, %narrow.out_xz = hw.instance "narrow" @ParamLogicState<W: i32 = 8>(d: %n: i8, d_xz: %n_xz: i8, clk: %clk_run_narrow: !seq.clock, rst: %rst_run_narrow: i1) -> (out: i8, out_xz: i8)
  %wide.out, %wide.out_xz = hw.instance "wide" @ParamLogicState<W: i32 = 16>(d: %w: i16, d_xz: %w_xz: i16, clk: %clk_run_wide: !seq.clock, rst: %rst_run_wide: i1) -> (out: i16, out_xz: i16)
  hw.output %narrow.out, %narrow.out_xz, %wide.out, %wide.out_xz : i8, i8, i16, i16
}
