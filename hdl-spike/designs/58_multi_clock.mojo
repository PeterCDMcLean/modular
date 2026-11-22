"""Positive: independent state and memories in two clock domains."""

from hdl import Bits, Mem


@module
struct TwoIndependentMems:
    var a: Mem[Bits[8], 4]
    var b: Mem[Bits[8], 4]
    var ca: Bits[8]
    var cb: Bits[8]

    def __init__(out self):
        self.a = Mem[Bits[8], 4]()
        self.b = Mem[Bits[8], 4]()
        self.ca = Bits[8](0)
        self.cb = Bits[8](0)

    def run_a(mut self, wd_a: Bits[8], en_a: Bool) -> Bits[8]:
        self.a.write(0, wd_a, en_a)
        self.ca = self.ca + Bits[8](1)
        return self.a.read(0) ^ self.ca

    def run_b(mut self, wd_b: Bits[8], en_b: Bool) -> Bits[8]:
        self.b.write(0, wd_b, en_b)
        self.cb = self.cb + Bits[8](2)
        return self.b.read(0) ^ self.cb
