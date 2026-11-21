"""Typed Reg: .next sets the clocked update and .get reads the value."""

from hdl import Bits, Reg


@module
struct RegDemo:
    var count: Reg[8]
    var held: Reg[8]

    def __init__(out self):
        self.count = Reg[8](3)
        self.held = Reg[8](1)

    def run(mut self, en: Bool) -> Bits[8]:
        var next = self.count.get() + Bits[8](1)
        self.count.next(next)
        if en:
            self.held.next(self.held.get() + Bits[8](2))
        return self.count.get() ^ self.held.get()
