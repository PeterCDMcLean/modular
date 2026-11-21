"""Negative: one process reads state driven by another process/domain."""

from hdl import Bits


@module
struct BadCrossRead:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run_a(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()

    def run_b(self) -> Bits[8]:
        return self.count.copy()
