"""Packed constant reset and unwritten-register hold behavior."""

from hdl import Bits, Packed, Reg


@module
struct PackedConstHold:
    var r: Reg[Packed[Bits[8], 4]]

    def __init__(out self):
        self.r = Reg[Packed[Bits[8], 4]](Packed[Bits[8], 4](0x04030201))

    def run(mut self) -> Packed[Bits[8], 4]:
        return self.r.get()


@module
struct UnwrittenBits:
    var q: Reg[Bits[8]]

    def __init__(out self):
        self.q = Reg[Bits[8]](7)

    def run(mut self) -> Bits[8]:
        return self.q.get()
