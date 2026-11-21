"""Per-register reset styles: Resettable[8,0] and Resettable[8,2]."""

from hdl import Bits, Resettable


@module
struct MixedReset:
    var sync_count: Resettable[8, 0]
    var async_count: Resettable[8, 2]

    def __init__(out self):
        self.sync_count = Resettable[8, 0](3)
        self.async_count = Resettable[8, 2](5)

    def sync_step(mut self) -> Bits[8]:
        self.sync_count = self.sync_count + Resettable[8, 0](1)
        return self.sync_count.get()

    def async_step(mut self) -> Bits[8]:
        self.async_count = self.async_count + Resettable[8, 2](1)
        return self.async_count.get()
