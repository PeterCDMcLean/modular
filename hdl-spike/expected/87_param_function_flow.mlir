hw.module @Clamped<W: i32 = 8>(in %a : !hw.int<#hw.param.verbatim<"hdl_clamp(W, 16, 64)">>, out out : !hw.int<#hw.param.verbatim<"hdl_clamp(W, 16, 64)">>) {
  hw.output %a : !hw.int<#hw.param.verbatim<"hdl_clamp(W, 16, 64)">>
}
