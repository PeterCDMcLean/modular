hw.module @Passthrough<W: i32>(in %a : !hw.int<#hw.param.decl.ref<"W">>, out out : !hw.int<#hw.param.decl.ref<"W">>) {
  hw.output %a : !hw.int<#hw.param.decl.ref<"W">>
}
hw.module @Scaled<W: i32>(in %a : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, 1>>, out out : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, 1>>) {
  hw.output %a : !hw.int<#hw.param.expr.add<#hw.param.decl.ref<"W">, 1>>
}
hw.module @ScaledUsers(in %si : i9, in %li : i17, out run_small_out : i9, out run_large_out : i17) {
  %small.out = hw.instance "small" @Scaled<W: i32 = 8>(a: %si: i9) -> (out: i9)
  %large.out = hw.instance "large" @Scaled<W: i32 = 16>(a: %li: i17) -> (out: i17)
  hw.output %small.out, %large.out : i9, i17
}
hw.module @TwoWidths(in %ni : i8, in %wi : i16, out run_narrow_out : i8, out run_wide_out : i16) {
  %narrow.out = hw.instance "narrow" @Passthrough<W: i32 = 8>(a: %ni: i8) -> (out: i8)
  %wide.out = hw.instance "wide" @Passthrough<W: i32 = 16>(a: %wi: i16) -> (out: i16)
  hw.output %narrow.out, %wide.out : i8, i16
}
