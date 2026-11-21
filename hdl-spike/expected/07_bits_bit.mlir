hw.module @BitSelect(in %a : i12, out out : i1) {
  %0 = comb.extract %a from 3 : (i12) -> i1
  hw.output %0 : i1
}
