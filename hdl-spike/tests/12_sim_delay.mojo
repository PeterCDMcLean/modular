from hdl import Bits, Reg, SimModule, step


struct SimDomain(SimModule):
    var a: Reg[Bits[8]]
    var b: Reg[Bits[8]]
    var din: Bits[8]

    def __init__(out self):
        self.a = Reg[Bits[8]]()
        self.b = Reg[Bits[8]]()
        self.din = Bits[8]()

    def evaluate(mut self):
        # Two process calls in one domain traversal.
        self.a.next(1) <= self.din
        self.b.next(1) <= self.a.get()

    def cycle(mut self, din: Bits[8]) -> Tuple[Bits[8], Bits[8]]:
        self.din = din.copy()
        step(self)
        return (self.a.get(), self.b.get())


def main():
    var sim = SimDomain()
    var c0 = sim.cycle(Bits[8](1))
    print("c0", c0[0].to_int(), c0[1].to_int())
    var c1 = sim.cycle(Bits[8](2))
    print("c1", c1[0].to_int(), c1[1].to_int())
    var c2 = sim.cycle(Bits[8](3))
    print("c2", c2[0].to_int(), c2[1].to_int())
