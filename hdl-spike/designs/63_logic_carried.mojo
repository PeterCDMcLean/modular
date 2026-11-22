"""Loop-carried Logic state: value and mask registers across iterations."""

from hdl import Bits, Logic


@module
struct RuntimeForLogicAccum:
    var total: Logic[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Logic[8]()
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, wd: Logic[8]) -> Logic[8]:
        var acc = wd.copy()
        for _ in range(count):
            acc = acc | wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()


@module
struct RuntimeWhileLogicAccum:
    var total: Logic[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Logic[8]()
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, wd: Logic[8]) -> Logic[8]:
        var acc = wd.copy()
        var i = 0
        while i < count:
            acc = acc | wd.copy()
            i += 1
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
