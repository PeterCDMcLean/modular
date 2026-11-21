"""Two write ports with defined priority: the later write wins."""

from hdl import Bits, Mem


@module
struct MemTwoWrites:
    var mem: Mem[Bits[8], 4]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4](1, 2, 3, 4)

    def run(
        mut self,
        wa: Int,
        wd: Bits[8],
        we: Bool,
        wb: Int,
        wd2: Bits[8],
        we2: Bool,
        ra: Int,
    ) -> Bits[8]:
        self.mem.write(wa, wd, we)
        self.mem.write(wb, wd2, we2)
        return self.mem.read(ra)
