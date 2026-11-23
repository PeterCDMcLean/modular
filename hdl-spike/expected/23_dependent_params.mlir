hw.module @DepCounter<W: i32 = 8, E: i32 = 1>(in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>) {
  %0 = sv.verbatim.expr "(E + W)'(E)" : () -> !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>
  %1 = sv.verbatim.expr "(E + W)'(0)" : () -> !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>
  %2 = sv.verbatim.expr "(E + W)'(0)" : () -> !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>
  %3 = seq.compreg %4, %clk reset %rst, %2 : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>  
  %4 = comb.add %3, %0 : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>
  hw.output %3 : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"E">, #hw.param.decl.ref<"W">>>
}
hw.module @DepTop(in %clk_run_a : !seq.clock, in %rst_run_a : i1, in %clk_run_b : !seq.clock, in %rst_run_b : i1, out run_a_out : i9, out run_b_out : i20) {
  %a.out = hw.instance "a" @DepCounter<W: i32 = 8, E: i32 = 1>(clk: %clk_run_a: !seq.clock, rst: %rst_run_a: i1) -> (out: i9)
  %b.out = hw.instance "b" @DepCounter<W: i32 = 16, E: i32 = 4>(clk: %clk_run_b: !seq.clock, rst: %rst_run_b: i1) -> (out: i20)
  hw.output %a.out, %b.out : i9, i20
}
