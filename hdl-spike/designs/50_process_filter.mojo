"""Only no-argument, no-result methods are Sim processes."""

from hdl import Bits, Reg


@module
struct FilteredDomain:
    var count: Reg[Bits[8]]

    def __init__(out self):
        self.count = Reg[Bits[8]]()

    def tick(mut self, en: Bool):
        if en:
            self.count.next(1) <= self.count.get() + Bits[8](1)

    def status(self) -> Bits[8]:
        return self.count.get()

    def p1(mut self):
        self.count.next(1) <= self.count.get() + Bits[8](1)
