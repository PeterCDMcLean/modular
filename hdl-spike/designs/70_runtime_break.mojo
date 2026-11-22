"""Dynamic break in a runtime loop: a conditional early exit."""

from hdl import Bits


@module
struct RuntimeBreak:
    var total: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, stop: Bool, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        for _ in range(count):
            acc = acc + wd.copy()
            if stop:
                break
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()


@module
struct RuntimeWhileBreak:
    var total: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, stop: Bool, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        var i = 0
        while i < count:
            acc = acc + wd.copy()
            if stop:
                break
            i += 1
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
