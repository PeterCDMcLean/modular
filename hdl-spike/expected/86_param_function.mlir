hw.module @MaxWidth<W: i32>(in %a : !hw.int<#hw.param.verbatim<"hdl_max(W, 16)">>, out out : !hw.int<#hw.param.verbatim<"hdl_max(W, 16)">>) {
  hw.output %a : !hw.int<#hw.param.verbatim<"hdl_max(W, 16)">>
}
