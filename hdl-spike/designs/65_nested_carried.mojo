"""Loop-carried state across nested runtime loops."""

from hdl import Bits, Logic


@module
struct NestedAccum:
    var total: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, outer: Int, inner: Int, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        for _ in range(outer):
            for _ in range(inner):
                acc = acc + wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()


@module
struct NestedLogicAccum:
    var total: Logic[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Logic[8]()
        self.cycles = Bits[8](0)

    def run(mut self, outer: Int, inner: Int, wd: Logic[8]) -> Logic[8]:
        var acc = wd.copy()
        for _ in range(outer):
            for _ in range(inner):
                acc = acc | wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
