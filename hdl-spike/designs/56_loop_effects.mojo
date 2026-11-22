"""Looped process effects: constant-bounded loops are unrolled."""

from hdl import Bits, Mem


@module
struct LoopSum:
    def __init__(out self):
        pass

    def run(self, a: Bits[8], b: Bits[8]) -> Bits[8]:
        var acc = a.copy()
        for _ in range(4):
            acc = acc + b
        return acc^


@module
struct WhileSum:
    def __init__(out self):
        pass

    def run(self, a: Bits[8], b: Bits[8]) -> Bits[8]:
        var acc = a.copy()
        var i = 0
        while i < 4:
            acc = acc + b
            i += 1
        return acc^


@module
struct LoopMemWrite:
    var mem: Mem[Bits[8], 4]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()

    def run(mut self, wd: Bits[8], en: Bool) -> Bits[8]:
        for i in range(4):
            self.mem.write(i, wd, en)
        return self.mem.read(2)


@module
struct AccCell:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run(mut self, delta: Bits[8]) -> Bits[8]:
        self.count = self.count + delta
        return self.count.copy()


@module
struct LoopSelectiveTick:
    var cell: AccCell
    var last: Bits[8]

    def __init__(out self):
        self.cell = AccCell()
        self.last = Bits[8](0)

    def run(mut self, delta: Bits[8]) -> Bits[8]:
        for i in range(4):
            if i == 2:
                self.last = self.cell.run(delta)
        return self.last.copy()
