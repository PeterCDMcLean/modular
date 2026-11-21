"""Async memory: Mem entries use seq.firreg and per-entry write muxes."""

from hdl import Bits, Mem, ResetStyle


@module
struct AsyncMem:
    var rst_style: ResetStyle[2]
    var mem: Mem[Bits[8], 4]

    def __init__(out self):
        self.rst_style = ResetStyle[2]()
        self.mem = Mem[Bits[8], 4](5)

    def run(mut self, addr: Int, wdata: Bits[8], we: Bool) -> Bits[8]:
        self.mem.write(addr, wdata, we)
        return self.mem.read(addr)
