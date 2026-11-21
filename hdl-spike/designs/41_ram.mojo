"""Explicit RAM: Ram[Bits[8],4] lowers through seq.hlmem to an SV memory."""

from hdl import Bits, Ram


@module
struct RamDemo:
    var ram: Ram[Bits[8], 4]

    def __init__(out self):
        self.ram = Ram[Bits[8], 4]()

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        self.ram.write(addr, wd, we)
        return self.ram.read(addr)
