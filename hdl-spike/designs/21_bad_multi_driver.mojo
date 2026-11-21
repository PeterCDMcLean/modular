"""Negative: one state field driven by two processes/domains."""

from hdl import Bits


@module
struct BadMultiDriver:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run_a(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()

    def run_b(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](2)
        return self.count.copy()
