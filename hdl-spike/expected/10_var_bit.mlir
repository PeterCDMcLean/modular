hw.module @BitPick(in %a : i12, in %i : i64, out out : i1) {
  %0 = comb.extract %i from 0 : (i64) -> i12
  %1 = comb.shru %a, %0 : i12
  %2 = comb.extract %1 from 0 : (i12) -> i1
  hw.output %2 : i1
}
