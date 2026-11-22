"""Conditional returns: method results are muxed over branch conditions."""

from hdl import Bits, Logic


@module
struct ReturnMux:
    def __init__(out self):
        pass

    def pick(self, sel: Bool, a: Bits[8], b: Bits[8]) -> Bits[8]:
        if sel:
            return a.copy()
        else:
            return b.copy()


@module
struct ReturnFallthrough:
    def __init__(out self):
        pass

    def pick(self, sel: Bool, a: Bits[8], b: Bits[8]) -> Bits[8]:
        if sel:
            return a.copy()
        return b.copy()


@module
struct AccCell:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run(mut self, delta: Bits[8]) -> Bits[8]:
        self.count = self.count + delta
        return self.count.copy()


@module
struct ReturnInstance:
    var cell: AccCell

    def __init__(out self):
        self.cell = AccCell()

    def step(mut self, sel: Bool, a: Bits[8], b: Bits[8]) -> Bits[8]:
        if sel:
            return self.cell.run(a)
        else:
            return self.cell.run(b)


@module
struct LogicReturn:
    def __init__(out self):
        pass

    def pick(self, sel: Bool, a: Logic[8], b: Logic[8]) -> Logic[8]:
        if sel:
            return a.copy()
        else:
            return b.copy()
