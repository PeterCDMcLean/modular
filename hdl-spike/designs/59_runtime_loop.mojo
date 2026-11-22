"""Runtime-bounded loop: one iteration per clock."""

from hdl import Bits, Mem


@module
struct RuntimeFill:
    var mem: Mem[Bits[8], 4]
    var last: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()
        self.last = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8], en: Bool) -> Bits[8]:
        var i = 0
        while i < count:
            self.mem.write(i, wd, en)
            self.last = wd.copy()
            i += 1
        return self.last.copy()
