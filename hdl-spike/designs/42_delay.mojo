"""Delayed updates and look-back: `.next(n) <=` and `.past(n)`."""

from hdl import Bits, Reg


@module
struct NextDelay:
    var d: Reg[Bits[8]]

    def __init__(out self):
        self.d = Reg[Bits[8]]()

    def run(mut self, din: Bits[8]) -> Bits[8]:
        self.d.next(2) <= din
        return self.d.get()


@module
struct PastDelay:
    var d: Reg[Bits[8]]

    def __init__(out self):
        self.d = Reg[Bits[8]]()

    def run(mut self, din: Bits[8]) -> Bits[8]:
        self.d.next(din)
        return self.d.past(2)
