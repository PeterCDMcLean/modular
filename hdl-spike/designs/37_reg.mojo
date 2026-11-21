"""Typed Reg: .next sets the clocked update and .get reads the value."""

from hdl import Bits, Reg


@module
struct RegDemo:
    var count: Reg[Bits[8]]
    var held: Reg[Bits[8]]

    def __init__(out self):
        self.count = Reg[Bits[8]](3)
        self.held = Reg[Bits[8]](1)

    def run(mut self, en: Bool) -> Bits[8]:
        var next = self.count.get() + Bits[8](1)
        self.count.next(1) <= next
        if en:
            self.held.next(1) <= self.held.get() + Bits[8](2)
        return self.count.get() ^ self.held.get()
