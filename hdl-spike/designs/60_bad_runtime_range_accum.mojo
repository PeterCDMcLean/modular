"""Negative: a loop-carried local in a runtime range loop."""

from hdl import Bits


@module
struct RuntimeForAccum:
    var total: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        for i in range(count):
            acc = acc + wd.copy()
        self.total = acc.copy()
        return self.total.copy()
