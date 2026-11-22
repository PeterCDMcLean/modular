"""Negative: a Ram written in one domain and read in another."""

from hdl import Bits, Ram


@module
struct RamCrossRead:
    var ram: Ram[Bits[8], 4]

    def __init__(out self):
        self.ram = Ram[Bits[8], 4]()

    def run_a(mut self, wd: Bits[8], en: Bool) -> Bits[8]:
        self.ram.write(0, wd, en)
        return Bits[8](0)

    def run_b(self) -> Bits[8]:
        return self.ram.read(0)
