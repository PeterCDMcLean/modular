"""Negative: a Mem written in one domain and read in another."""

from hdl import Bits, Mem


@module
struct MemCrossRead:
    var mem: Mem[Bits[8], 4]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()

    def run_a(mut self, wd: Bits[8], en: Bool) -> Bits[8]:
        self.mem.write(0, wd, en)
        return Bits[8](0)

    def run_b(self) -> Bits[8]:
        return self.mem.read(0)
