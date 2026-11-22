"""Carried state inside a sequenced runtime loop."""

from hdl import Bits, Logic, Mem


@module
struct SequencedAccum:
    var mem: Mem[Bits[8], 4]
    var total: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()
        self.total = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, n: Int, m: Int, wd: Bits[8]) -> Bits[8]:
        for i in range(n):
            self.mem.write(i, wd, True)
        var acc = Bits[8](0)
        for _ in range(m):
            acc = acc + wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()


@module
struct SequencedLogicAccum:
    var seen: Bits[8]
    var total: Logic[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.seen = Bits[8](0)
        self.total = Logic[8]()
        self.cycles = Bits[8](0)

    def run(mut self, n: Int, m: Int, wd: Logic[8]) -> Logic[8]:
        for _ in range(n):
            self.seen = self.seen + Bits[8](1)
        var acc = wd.copy()
        for _ in range(m):
            acc = acc | wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
