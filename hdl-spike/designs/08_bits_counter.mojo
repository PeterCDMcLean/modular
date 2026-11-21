"""Bits[W] state: a struct field becomes a seq.compreg of width W."""

from hdl import Bits


@module
struct BitsCounter:
    var count: Bits[12]

    def __init__(out self):
        self.count = Bits[12](0)

    def run(mut self) -> Bits[12]:
        self.count = self.count + Bits[12](1)
        return self.count.copy()
