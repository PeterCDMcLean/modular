"""Packed arrays: Packed[Bits[8],4] flattens to a 32-bit port/register."""

from hdl import Bits, Packed, Reg


@module
struct PackedPass:
    def run(mut self, din: Packed[Bits[8], 4]) -> Packed[Bits[8], 4]:
        return din.copy()


@module
struct PackedHold:
    var r: Reg[Packed[Bits[8], 4]]

    def __init__(out self):
        self.r = Reg[Packed[Bits[8], 4]]()

    def run(mut self, din: Packed[Bits[8], 4]) -> Packed[Bits[8], 4]:
        self.r.next(1) <= din
        return self.r.get()


@module
struct PackedConstOut:
    def run(mut self) -> Packed[Bits[8], 4]:
        return Packed[Bits[8], 4](0x04030201)
