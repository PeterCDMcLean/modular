from hdl import Bits, Reg


struct SimDelay:
    var d: Reg[Bits[8]]

    def __init__(out self):
        self.d = Reg[Bits[8]]()

    def tick(mut self):
        self.d.tick()


def main():
    var sim = SimDelay()
    sim.d.next(1) <= Bits[8](1)
    sim.d.next(3) <= Bits[8](3)

    print("t0", sim.d.get().to_int(), sim.d.past(1).to_int())
    sim.tick()
    print("t1", sim.d.get().to_int(), sim.d.past(1).to_int(), sim.d.past(2).to_int())
    sim.tick()
    print("t2", sim.d.get().to_int(), sim.d.past(1).to_int(), sim.d.past(2).to_int())
    sim.tick()
    print(
        "t3",
        sim.d.get().to_int(),
        sim.d.past(1).to_int(),
        sim.d.past(2).to_int(),
        sim.d.past(3).to_int(),
    )

    var e = Reg[Bits[8]]()
    e.next(2) <= Bits[8](9)
    print("e0", e.get().to_int())
    e.tick()
    print("e1", e.get().to_int())
    e.tick()
    print("e2", e.get().to_int(), e.past(1).to_int(), e.past(2).to_int())
