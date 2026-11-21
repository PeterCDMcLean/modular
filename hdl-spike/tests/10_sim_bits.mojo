from hdl import Bits, mux


def main():
    var a = Bits[8](3)
    var b = Bits[8](4)
    print("a+b", (a + b).to_int())
    print("a&b", (a & b).to_int())
    print("a|b", (a | b).to_int())
    print("a^b", (a ^ b).to_int())
    print("mux", mux(True, a, b).to_int())
    print("mux0", mux(False, a, b).to_int())
    var c = Bits[8](0xFF)
    print("wrap", (c + Bits[8](1)).to_int())
