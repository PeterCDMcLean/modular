"""Nested struct fields carried across runtime loops."""

from hdl import Bits, Logic


struct Inner:
    var value: Bits[8]
    var mask: Bits[8]

    def __init__(out self, v: Bits[8], m: Bits[8]):
        self.value = v.copy() + Bits[8](1)
        self.mask = m.copy()


struct Outer:
    var inner: Inner
    var tag: Bits[8]

    def __init__(out self, v: Bits[8], m: Bits[8], t: Bits[8]):
        self.inner = Inner(v.copy(), m.copy())
        self.tag = t.copy() + Bits[8](2)


struct LogicInner:
    var value: Logic[8]
    var count: Bits[4]

    def __init__(out self, v: Logic[8], c: Bits[4]):
        self.value = v.copy()
        self.count = c.copy()


struct LogicOuter:
    var inner: LogicInner

    def __init__(out self, v: Logic[8], c: Bits[4]):
        self.inner = LogicInner(v.copy(), c.copy())

    def merge(mut self, v: Logic[8]):
        self.inner.value = self.inner.value | v.copy()
        self.inner.count = self.inner.count + Bits[4](1)


@module
struct NestedCarry:
    var total: Bits[8]
    var last_mask: Bits[8]
    var tag: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.last_mask = Bits[8](0)
        self.tag = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8]) -> Bits[8]:
        var o = Outer(wd.copy(), Bits[8](4), Bits[8](3))
        for _ in range(count):
            o.inner.value = o.inner.value + wd.copy()
            o.inner.mask = o.inner.mask + Bits[8](1)
            o.tag = o.tag + Bits[8](1)
        self.total = o.inner.value.copy()
        self.last_mask = o.inner.mask.copy()
        self.tag = o.tag.copy()
        return self.total.copy()


@module
struct NestedMethodCarry:
    var total: Logic[8]
    var tag: Bits[4]

    def __init__(out self):
        self.total = Logic[8]()
        self.tag = Bits[4](0)

    def run(mut self, count: Int, init: Logic[8], wd: Logic[8]) -> Logic[8]:
        var o = LogicOuter(init.copy(), Bits[4](2))
        for _ in range(count):
            o.merge(wd.copy())
        self.total = o.inner.value.copy()
        self.tag = o.inner.count.copy()
        return self.total.copy()
