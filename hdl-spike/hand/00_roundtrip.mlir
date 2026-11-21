%true = "hw.constant"() <{value = true}> : () -> i1
%false = "hw.constant"() <{value = false}> : () -> i1
%y = "comb.xor"(%true, %false) : (i1, i1) -> i1
