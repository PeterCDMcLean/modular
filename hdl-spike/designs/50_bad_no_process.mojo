"""Negative: a @module with no Sim process method."""

from hdl import Bits, Reg


@module
struct NoProcess:
    var count: Reg[Bits[8]]

    def __init__(out self):
        self.count = Reg[Bits[8]]()

    def tick(mut self, en: Bool):
        if en:
            self.count.next(1) <= self.count.get() + Bits[8](1)

    def status(self) -> Bits[8]:
        return self.count.get()
