"""Shared carried Logic state across a restarting runtime sequence."""

from hdl import Bits, Logic


@module
struct SharedLogicAccum:
    var total: Logic[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Logic[8]()
        self.cycles = Bits[8](0)

    def run(mut self, n: Int, m: Int, wd: Logic[8]) -> Logic[8]:
        var acc = wd.copy()
        for _ in range(n):
            acc = acc | wd.copy()
        for _ in range(m):
            acc = acc | wd.copy()
        self.total = acc.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
