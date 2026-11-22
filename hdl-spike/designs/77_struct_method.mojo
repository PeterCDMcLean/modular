"""Plain Mojo struct methods updating carried fields inside a runtime loop."""

from hdl import Bits, Logic


struct Pair:
    var a: Bits[8]
    var b: Bits[8]

    def __init__(out self, a: Bits[8], b: Bits[8]):
        self.a = a.copy()
        self.b = b.copy()

    def bump(mut self, d: Bits[8]):
        self.a = self.a + d.copy()
        self.b = self.b + Bits[8](3)


struct LogicPair:
    var val: Logic[8]
    var tag: Bits[4]

    def __init__(out self, val: Logic[8], tag: Bits[4]):
        self.val = val.copy()
        self.tag = tag.copy()

    def merge(mut self, v: Logic[8]):
        self.val = self.val | v.copy()
        self.tag = self.tag + Bits[4](1)


@module
struct StructMethodCarry:
    var total: Bits[8]
    var other: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.other = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8]) -> Bits[8]:
        var p = Pair(wd.copy(), Bits[8](2))
        for _ in range(count):
            p.bump(wd.copy())
        self.total = p.a.copy()
        self.other = p.b.copy()
        return self.total.copy()


@module
struct LogicStructMethodCarry:
    var total: Logic[8]
    var tag: Bits[4]

    def __init__(out self):
        self.total = Logic[8]()
        self.tag = Bits[4](0)

    def run(mut self, count: Int, init: Logic[8], wd: Logic[8]) -> Logic[8]:
        var p = LogicPair(init.copy(), Bits[4](5))
        for _ in range(count):
            p.merge(wd.copy())
        self.total = p.val.copy()
        self.tag = p.tag.copy()
        return self.total.copy()
