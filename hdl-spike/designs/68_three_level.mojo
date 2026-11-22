"""Three-level runtime loop nesting."""

from hdl import Bits, Mem


@module
struct ThreeLevelFill:
    var mem: Mem[Bits[8], 8]
    var last: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 8]()
        self.last = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(
        mut self, a: Int, b: Int, c: Int, wd: Bits[8], en: Bool
    ) -> Bits[8]:
        for i in range(a):
            for j in range(b):
                for k in range(c):
                    self.mem.write(i * 4 + j * 2 + k, wd, en)
                    self.last = wd.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.last.copy()
