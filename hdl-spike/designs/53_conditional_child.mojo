"""Conditional effects: one stateful child ticked in exclusive branches."""

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
struct ConditionalTick:
    var cell: AccCell
    var last: Bits[8]

    def __init__(out self):
        self.cell = AccCell()
        self.last = Bits[8](0)

    def run(mut self, sel: Bool, a: Bits[8], b: Bits[8]) -> Bits[8]:
        if sel:
            self.last = self.cell.run(a)
        else:
            self.last = self.cell.run(b)
        return self.last.copy()


@module
struct ConditionalChain:
    var cell: AccCell
    var last: Bits[8]

    def __init__(out self):
        self.cell = AccCell()
        self.last = Bits[8](0)

    def run(
        mut self, sel_a: Bool, sel_b: Bool, a: Bits[8], b: Bits[8], c: Bits[8]
    ) -> Bits[8]:
        if sel_a:
            self.last = self.cell.run(a)
        else:
            if sel_b:
                self.last = self.cell.run(b)
            else:
                self.last = self.cell.run(c)
        return self.last.copy()
