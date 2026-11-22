"""Negative: a carried local declared inside the outer runtime loop."""

from hdl import Bits


@module
struct NestedInnerLocal:
    var total: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)

    def run(mut self, outer: Int, inner: Int, wd: Bits[8]) -> Bits[8]:
        for i in range(outer):
            var acc = Bits[8](0)
            for _ in range(inner):
                acc = acc + wd.copy()
            self.total = acc.copy()
        return self.total.copy()
