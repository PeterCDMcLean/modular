"""Negative: overlapping conditional ticks of one stateful child."""

from hdl import Bits


@module
struct AccCell:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run(mut self, delta: Bits[8]) -> Bits[8]:
        self.count = self.count + delta
        return self.count.copy()


@module
struct ParallelTick:
    var cell: AccCell
    var x: Bits[8]
    var y: Bits[8]

    def __init__(out self):
        self.cell = AccCell()
        self.x = Bits[8](0)
        self.y = Bits[8](0)

    def run(mut self, a: Bool, b: Bool) -> Bits[8]:
        if a:
            self.x = self.cell.run(Bits[8](1))
        if b:
            self.y = self.cell.run(Bits[8](2))
        return self.x ^ self.y
