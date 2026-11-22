"""Value-returning struct methods used inside runtime loops."""

from hdl import Bits, Logic


struct Counter:
    var value: Bits[8]

    def __init__(out self, v: Bits[8]):
        self.value = v.copy()

    def pick(mut self, en: Bool, d: Bits[8]) -> Bits[8]:
        if en:
            return d.copy()
        return self.value.copy()

    def bump(mut self, d: Bits[8]) -> Bits[8]:
        self.value = self.value + d.copy()
        return self.value.copy()


struct LogicCell:
    var value: Logic[8]

    def __init__(out self, v: Logic[8]):
        self.value = v.copy()

    def merge(mut self, v: Logic[8]) -> Logic[8]:
        self.value = self.value | v.copy()
        return self.value.copy()


@module
struct ConditionalReturnMethod:
    var total: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)

    def run(mut self, count: Int, en: Bool, wd: Bits[8]) -> Bits[8]:
        var o = Counter(wd.copy())
        var acc = Bits[8](0)
        var i = 0
        while i < count:
            var r = o.pick(en, wd.copy())
            acc = acc + r.copy()
            var s = o.bump(wd.copy())
            acc = acc + s.copy()
            i += 1
        self.total = acc.copy()
        return self.total.copy()


@module
struct LogicValueMethod:
    var total: Logic[8]

    def __init__(out self):
        self.total = Logic[8]()

    def run(mut self, count: Int, init: Logic[8], wd: Logic[8]) -> Logic[8]:
        var o = LogicCell(init.copy())
        var acc = init.copy()
        var i = 0
        while i < count:
            var r = o.merge(wd.copy())
            acc = acc | r.copy()
            i += 1
        self.total = acc.copy()
        return self.total.copy()
