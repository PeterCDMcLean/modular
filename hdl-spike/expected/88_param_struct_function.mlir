hw.module @ClampedPacked<W: i32 = 8>(in %a : !hw.int<#hw.param.verbatim<"hdl_clamp_packed(W, hdl_PackedLimits'{f0: 4, f1: 32})">>, out out : !hw.int<#hw.param.verbatim<"hdl_clamp_packed(W, hdl_PackedLimits'{f0: 4, f1: 32})">>) {
  hw.output %a : !hw.int<#hw.param.verbatim<"hdl_clamp_packed(W, hdl_PackedLimits'{f0: 4, f1: 32})">>
}
hw.module @ClampedUnpacked<W: i32 = 8>(in %a : !hw.int<#hw.param.verbatim<"hdl_clamp_to(W, hdl_Limits'{f0: 16, f1: 64})">>, out out : !hw.int<#hw.param.verbatim<"hdl_clamp_to(W, hdl_Limits'{f0: 16, f1: 64})">>) {
  hw.output %a : !hw.int<#hw.param.verbatim<"hdl_clamp_to(W, hdl_Limits'{f0: 16, f1: 64})">>
}
