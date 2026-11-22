"""Two runtime loops in sequence: the second starts on the first's done."""

from hdl import Bits, Mem


@module
struct SequencedLoops:
    var mem: Mem[Bits[8], 8]
    var last: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 8]()
        self.last = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(
        mut self, n: Int, m: Int, wd: Bits[8], en: Bool
    ) -> Bits[8]:
        for i in range(n):
            self.mem.write(i, wd, en)
            self.last = wd.copy()
        for j in range(m):
            self.mem.write(j, wd, en)
            self.last = wd.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.last.copy()


@module
struct SequencedWhile:
    var mem: Mem[Bits[8], 8]
    var last: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 8]()
        self.last = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(
        mut self, n: Int, m: Int, wd: Bits[8], en: Bool
    ) -> Bits[8]:
        for i in range(n):
            self.mem.write(i, wd, en)
            self.last = wd.copy()
        var j = 0
        while j < m:
            self.mem.write(j, wd, en)
            self.last = wd.copy()
            j += 1
        self.cycles = self.cycles + Bits[8](1)
        return self.last.copy()
