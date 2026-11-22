"""Nested runtime loops: an inner range loop inside an outer range loop."""

from hdl import Bits, Mem


@module
struct NestedRuntimeFill:
    var mem: Mem[Bits[8], 8]
    var last: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.mem = Mem[Bits[8], 8]()
        self.last = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(
        mut self, outer: Int, inner: Int, wd: Bits[8], en: Bool
    ) -> Bits[8]:
        for i in range(outer):
            for j in range(inner):
                self.mem.write(i * 2 + j, wd, en)
                self.last = wd.copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.last.copy()
