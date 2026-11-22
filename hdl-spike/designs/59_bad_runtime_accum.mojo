"""Negative: a loop-carried local in a runtime-bounded loop."""

from hdl import Bits


@module
struct RuntimeAccum:
    var total: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        var i = 0
        while i < count:
            acc = acc + wd.copy()
            i += 1
        self.total = acc.copy()
        return self.total.copy()
