from hdl import Bits, Logic, XMode, logic, mux_logic


def main():
    var a = logic[4](0b0011)
    var b = logic[4](0b0101)
    var c = a & b
    print("and", c.known().to_int(), c.xz.to_int(), c.is_known())
    var o = a | b
    print("or", o.known().to_int(), o.xz.to_int())
    var x = Logic[4, XMode.taint](Bits[4](0), Bits[4](0b0001))
    var mask = logic[4](0b1111)
    var dominant = x & mask
    print("dom", dominant.known().to_int(), dominant.xz.to_int())
    var propagated = x ^ mask
    print("xor", propagated.known().to_int(), propagated.xz.to_int())
    var cond = Logic[1, XMode.taint](Bits[1](0), Bits[1](1))
    var m = mux_logic(cond, logic[4](0b1100), logic[4](0b1010))
    print("mux", m.known().to_int(), m.xz.to_int())

    var eq_same = logic[4](0b0101) == logic[4](0b0101)
    print("eq", eq_same.known().to_int(), eq_same.xz.to_int())
    var eq_diff = logic[4](0b0101) == logic[4](0b0111)
    print("eqd", eq_diff.known().to_int(), eq_diff.xz.to_int())
    var eq_unknown = x == logic[4](0b0001)
    print("eqx", eq_unknown.known().to_int(), eq_unknown.xz.to_int())
    var ne_unknown = x != logic[4](0b0001)
    print("nex", ne_unknown.known().to_int(), ne_unknown.xz.to_int())
    var ne_diff = logic[4](0b0011) != logic[4](0b0101)
    print("ned", ne_diff.known().to_int(), ne_diff.xz.to_int())
    var ne_same = logic[4](0b0011) != logic[4](0b0011)
    print("nes", ne_same.known().to_int(), ne_same.xz.to_int())
