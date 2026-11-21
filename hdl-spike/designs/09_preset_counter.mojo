"""Constructor constants become the register's reset value."""

from hdl import Bits


@module
struct PresetCounter:
    var count: Bits[12]

    def __init__(out self):
        self.count = Bits[12](5)

    def run(mut self) -> Bits[12]:
        self.count = self.count + Bits[12](1)
        return self.count.copy()
