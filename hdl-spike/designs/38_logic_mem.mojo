"""4-state memory: Mem[Logic[8],4] as value/mask register pairs."""

from hdl import Logic, Mem


@module
struct LogicMem:
    var mem: Mem[Logic[8], 4]

    def __init__(out self):
        self.mem = Mem[Logic[8], 4](1, 2, 3, 4)

    def run(mut self, addr: Int, wd: Logic[8], we: Bool) -> Logic[8]:
        self.mem.write(addr, wd, we)
        return self.mem.read(addr)
