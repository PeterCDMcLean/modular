hw.module @DivMod<W: i32 = 8>(in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.decl.ref<"W">>) {
  %0 = sv.verbatim.expr "(W / 2)'(1)" : () -> !hw.int<#hw.param.verbatim<"(W / 2)">>
  %1 = sv.verbatim.expr "(W / 2)'(0)" : () -> !hw.int<#hw.param.verbatim<"(W / 2)">>
  %2 = sv.verbatim.expr "(W / 2)'(2)" : () -> !hw.int<#hw.param.verbatim<"(W / 2)">>
  %3 = seq.compreg %4, %clk reset %rst, %2 : !hw.int<#hw.param.verbatim<"(W / 2)">>  
  %4 = comb.add %3, %0 : !hw.int<#hw.param.verbatim<"(W / 2)">>
  %W = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  hw.output %W : !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @SubMod<W: i32 = 8>(in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.decl.ref<"W">>) {
  %0 = sv.verbatim.expr "(W - 1)'(1)" : () -> !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, -1>>
  %1 = sv.verbatim.expr "(W - 1)'(0)" : () -> !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, -1>>
  %2 = sv.verbatim.expr "(W - 1)'(1)" : () -> !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, -1>>
  %3 = seq.compreg %4, %clk reset %rst, %2 : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, -1>>  
  %4 = comb.add %3, %0 : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, -1>>
  %W = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  hw.output %W : !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @MaxMod<W: i32 = 8, E: i32 = 2>(in %clk : !seq.clock, in %rst : i1, out out : !hw.int<#hw.param.decl.ref<"W">>) {
  %0 = sv.verbatim.expr "((E < W) ? W : E)'(1)" : () -> !hw.int<#hw.param.verbatim<"((E < W) ? W : E)">>
  %1 = sv.verbatim.expr "((E < W) ? W : E)'(0)" : () -> !hw.int<#hw.param.verbatim<"((E < W) ? W : E)">>
  %2 = sv.verbatim.expr "((E < W) ? W : E)'(3)" : () -> !hw.int<#hw.param.verbatim<"((E < W) ? W : E)">>
  %3 = seq.compreg %4, %clk reset %rst, %2 : !hw.int<#hw.param.verbatim<"((E < W) ? W : E)">>  
  %4 = comb.add %3, %0 : !hw.int<#hw.param.verbatim<"((E < W) ? W : E)">>
  %W = sv.verbatim.expr "W'(0)" : () -> !hw.int<#hw.param.decl.ref<"W">>
  hw.output %W : !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @ExprTop(in %clk_run_s : !seq.clock, in %rst_run_s : i1, in %clk_run_d : !seq.clock, in %rst_run_d : i1, in %clk_run_m : !seq.clock, in %rst_run_m : i1, out run_s_out : i8, out run_d_out : i9, out run_m_out : i8) {
  %s.out = hw.instance "s" @SubMod<W: i32 = 8>(clk: %clk_run_s: !seq.clock, rst: %rst_run_s: i1) -> (out: i8)
  %d.out = hw.instance "d" @DivMod<W: i32 = 9>(clk: %clk_run_d: !seq.clock, rst: %rst_run_d: i1) -> (out: i9)
  %m.out = hw.instance "m" @MaxMod<W: i32 = 8, E: i32 = 2>(clk: %clk_run_m: !seq.clock, rst: %rst_run_m: i1) -> (out: i8)
  hw.output %s.out, %d.out, %m.out : i8, i9, i8
}
