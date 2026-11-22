"""Negative: a stateful child ticked every iteration of a loop."""

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
struct LoopChildTick:
    var cell: AccCell

    def __init__(out self):
        self.cell = AccCell()

    def run(mut self, delta: Bits[8]) -> Bits[8]:
        for i in range(2):
            self.cell.run(delta)
        return self.cell.count.copy()
