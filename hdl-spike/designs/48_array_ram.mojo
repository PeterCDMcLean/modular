"""Array-register memory: array_get/array_inject + enable mux."""

from hdl import ArrayRam, Bits


@module
struct ArrayRamDemo:
    var mem: ArrayRam[Bits[8], 4]

    def __init__(out self):
        self.mem = ArrayRam[Bits[8], 4]()

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        self.mem.write(addr, wd, we)
        return self.mem.read(addr)
