"""Runtime loop done handshake: post-loop code runs once per traversal."""

from hdl import Bits, Mem


@module
struct RuntimeForDone:
    var mem: Mem[Bits[8], 4]
    var last: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()
        self.last = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8], en: Bool) -> Bits[8]:
        for i in range(count):
            self.mem.write(i, wd, en)
            self.last = wd.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.cycles.copy()


@module
struct RuntimeWhileDone:
    var mem: Mem[Bits[8], 4]
    var last: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 4]()
        self.last = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8], en: Bool) -> Bits[8]:
        var i = 0
        while i < count:
            self.mem.write(i, wd, en)
            self.last = wd.copy()
            i += 1
        self.cycles = self.cycles + Bits[8](1)
        return self.cycles.copy()
