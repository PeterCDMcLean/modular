"""Mem[8,4]: per-entry clock-enabled registers and a read mux."""

from hdl import Bits, Mem


@module
struct MemTop:
    var mem: Mem[8, 4]

    def __init__(out self):
        self.mem = Mem[8, 4]()

    def run(mut self, addr: Int, wdata: Bits[8], we: Bool) -> Bits[8]:
        self.mem.write(addr, wdata, we)
        return self.mem.read(addr)
