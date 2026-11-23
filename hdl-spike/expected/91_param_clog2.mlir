hw.module @ClogCounter<W: i32 = 8>(in %clk : !seq.clock, in %rst : i1, out out : i1) {
  %0 = sv.verbatim.expr "($clog2(W))'(1)" : () -> !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>
  %1 = sv.verbatim.expr "($clog2(W))'(0)" : () -> !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>
  %2 = sv.verbatim.expr "($clog2(W))'(0)" : () -> !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>
  %3 = seq.compreg %4, %clk reset %rst, %2 : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>  
  %4 = comb.add %3, %0 : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>
  %false = hw.constant false
  hw.output %false : i1
}
hw.module @ClogPort<W: i32 = 8>(in %a : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>, out out : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>) {
  hw.output %a : !hw.int<#hw.param.expr.clog2<#hw.param.decl.ref<"W">>>
}
hw.module @ClogTop(in %clk_run_small : !seq.clock, in %rst_run_small : i1, in %clk_run_large : !seq.clock, in %rst_run_large : i1, out run_small_out : i1, out run_large_out : i1) {
  %small.out = hw.instance "small" @ClogCounter<W: i32 = 8>(clk: %clk_run_small: !seq.clock, rst: %rst_run_small: i1) -> (out: i1)
  %large.out = hw.instance "large" @ClogCounter<W: i32 = 32>(clk: %clk_run_large: !seq.clock, rst: %rst_run_large: i1) -> (out: i1)
  hw.output %small.out, %large.out : i1, i1
}
