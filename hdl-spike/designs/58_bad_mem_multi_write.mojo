"""Negative: a Mem written from two clock domains."""

from hdl import Bits, Mem


@module
struct MemMultiWrite:
    var mem: Mem[Bits[8], 4]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()

    def run_a(mut self, wd: Bits[8], en: Bool) -> Bits[8]:
        self.mem.write(0, wd, en)
        return self.mem.read(0)

    def run_b(mut self, wd_b: Bits[8], en_b: Bool) -> Bits[8]:
        self.mem.write(1, wd_b, en_b)
        return self.mem.read(1)
