"""Two read ports: two independent read muxes over the same entries."""

from hdl import Bits, Mem


@module
struct MemDualRead:
    var mem: Mem[Bits[8], 4]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4](1, 2, 3, 4)

    def run(mut self, addr_a: Int, addr_b: Int) -> Bits[8]:
        var a = self.mem.read(addr_a)
        var b = self.mem.read(addr_b)
        return a ^ b
