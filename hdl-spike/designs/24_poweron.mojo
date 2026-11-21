"""Explicit power-on: constructor reset (5) and power-on (9) differ."""

from hdl import Bits, PowerOn


@module
struct PowerOnCounter:
    var poweron: PowerOn[9]
    var count: Bits[8]

    def __init__(out self):
        self.poweron = PowerOn[9]()
        self.count = Bits[8](5)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()
