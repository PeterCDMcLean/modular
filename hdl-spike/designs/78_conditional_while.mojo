"""Carried while loops with conditional sequences and breaks."""

from hdl import Bits, Logic


@module
struct WhileConditionalCarry:
    var total: Bits[8]
    var passes: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.passes = Bits[8](0)

    def run(
        mut self, count: Int, a: Bool, b: Bool, wd: Bits[8]
    ) -> Bits[8]:
        var acc = Bits[8](0)
        var i = 0
        while i < count:
            acc = acc + wd.copy()
            if a:
                acc = acc + Bits[8](1)
                if b:
                    break
            else:
                acc = acc + Bits[8](2)
            i += 1
        self.total = acc.copy()
        self.passes = self.passes + Bits[8](1)
        return self.total.copy()


@module
struct LogicWhileConditional:
    var total: Logic[8]
    var passes: Bits[8]

    def __init__(out self):
        self.total = Logic[8]()
        self.passes = Bits[8](0)

    def run(
        mut self, count: Int, a: Bool, b: Bool, wd: Logic[8]
    ) -> Logic[8]:
        var acc = wd.copy()
        var i = 0
        while i < count:
            if a:
                acc = acc | wd.copy()
                if b:
                    break
            else:
                acc = acc & wd.copy()
            i += 1
        self.total = acc.copy()
        self.passes = self.passes + Bits[8](1)
        return self.total.copy()
