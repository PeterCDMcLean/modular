"""Carried state shared across both loops of a runtime sequence."""

from hdl import Bits


@module
struct SharedAccum:
    var total: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, n: Int, m: Int, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        for _ in range(n):
            acc = acc + wd.copy()
        for _ in range(m):
            acc = acc + wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
