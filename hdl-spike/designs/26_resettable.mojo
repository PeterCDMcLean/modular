"""Per-register reset styles: Reg[Bits[8], style] sync and async."""

from hdl import Bits, Reg


@module
struct MixedReset:
    var sync_count: Reg[Bits[8], 0]
    var async_count: Reg[Bits[8], 2]

    def __init__(out self):
        self.sync_count = Reg[Bits[8], 0](3)
        self.async_count = Reg[Bits[8], 2](5)

    def sync_step(mut self) -> Bits[8]:
        self.sync_count.next(1) <= self.sync_count.get() + Bits[8](1)
        return self.sync_count.get()

    def async_step(mut self) -> Bits[8]:
        self.async_count.next(1) <= self.async_count.get() + Bits[8](1)
        return self.async_count.get()
