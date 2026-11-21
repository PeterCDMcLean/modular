"""Arbitrary-depth memory initialization: Mem[8,2](7,9)."""

from hdl import Bits, Mem


@module
struct MemDepth2:
    var mem: Mem[8, 2]

    def __init__(out self):
        self.mem = Mem[8, 2](7, 9)

    def run(mut self, addr: Int, wdata: Bits[8], we: Bool) -> Bits[8]:
        self.mem.write(addr, wdata, we)
        return self.mem.read(addr)
