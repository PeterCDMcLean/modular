"""Two-process design discovered by the Sim step generator."""

from hdl import Bits, Reg


@module
struct AutoDomain:
    var a: Reg[Bits[8]]
    var b: Reg[Bits[8]]
    var din: Bits[8]

    def __init__(out self):
        self.a = Reg[Bits[8]]()
        self.b = Reg[Bits[8]]()
        self.din = Bits[8]()

    # @process
    def p1(mut self):
        self.a.next(1) <= self.din

    # @process
    def p2(mut self):
        self.b.next(1) <= self.a.get()
