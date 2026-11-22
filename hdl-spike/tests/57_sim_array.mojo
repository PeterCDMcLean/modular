from hdl import Array, Bits, Logic, Reg


def main():
    var a = Array[Bits[8], 4](0x04030201)
    print("a", a[0].to_int(), a[1].to_int(), a[2].to_int(), a[3].to_int())
    a[2] = Bits[8](9)
    print("set", a[0].to_int(), a[2].to_int())

    var b = a.copy()
    print("copy", b[2].to_int())

    var l = Array[Logic[8], 4]()
    l[1] = Logic[8](5)
    print("logic", l[1].known().to_int(), l[1].xz.to_int())

    var r = Reg[Array[Bits[8], 4]]()
    r.next(1) <= a
    r.commit()
    var got = r.get()
    print("reg", got[2].to_int(), got[0].to_int())
