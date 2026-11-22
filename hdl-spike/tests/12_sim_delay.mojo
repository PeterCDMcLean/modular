from hdl import Array, Bits, Reg, SimModule, step


struct Child(Defaultable, Copyable, Movable):
    var r: Reg[Bits[8]]

    def __init__(out self):
        self.r = Reg[Bits[8]]()


struct SimDomain(SimModule):
    var a: Reg[Bits[8]]
    var b: Reg[Bits[8]]
    var din: Bits[8]

    def __init__(out self):
        self.a = Reg[Bits[8]]()
        self.b = Reg[Bits[8]]()
        self.din = Bits[8]()

    def p1(mut self):
        self.a.next(1) <= self.din

    def p2(mut self):
        self.b.next(1) <= self.a.get()

    def cycle(mut self, din: Bits[8]) -> Tuple[Bits[8], Bits[8]]:
        self.din = din.copy()
        step(self, Self.p1, Self.p2)
        return (self.a.get(), self.b.get())


struct SimArrayDomain(SimModule):
    var regs: Array[Reg[Bits[8]], 2]
    var children: Array[Child, 2]
    var din: Bits[8]

    def __init__(out self):
        self.regs = Array[Reg[Bits[8]], 2]()
        self.children = Array[Child, 2]()
        self.din = Bits[8]()

    def p1(mut self):
        var r0 = self.regs[0].copy()
        r0.next(1) <= self.din
        self.regs[0] = r0^
        var r1 = self.regs[1].copy()
        r1.next(1) <= self.regs[0].get()
        self.regs[1] = r1^

    def p2(mut self):
        var c0 = self.children[0].copy()
        c0.r.next(1) <= self.din
        self.children[0] = c0^
        var c1 = self.children[1].copy()
        c1.r.next(1) <= self.children[0].r.get()
        self.children[1] = c1^

    def cycle(mut self, din: Bits[8]) -> Tuple[Int, Int, Int, Int]:
        self.din = din.copy()
        step(self, Self.p1, Self.p2)
        return (
            self.regs[0].get().to_int(),
            self.regs[1].get().to_int(),
            self.children[0].r.get().to_int(),
            self.children[1].r.get().to_int(),
        )


def main():
    var sim = SimDomain()
    var c0 = sim.cycle(Bits[8](1))
    print("c0", c0[0].to_int(), c0[1].to_int())
    var c1 = sim.cycle(Bits[8](2))
    print("c1", c1[0].to_int(), c1[1].to_int())
    var c2 = sim.cycle(Bits[8](3))
    print("c2", c2[0].to_int(), c2[1].to_int())

    var arr = SimArrayDomain()
    var a0 = arr.cycle(Bits[8](1))
    print("a0", a0[0], a0[1], a0[2], a0[3])
    var a1 = arr.cycle(Bits[8](2))
    print("a1", a1[0], a1[1], a1[2], a1[3])
