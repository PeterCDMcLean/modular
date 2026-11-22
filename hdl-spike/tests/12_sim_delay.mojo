from hdl import Bits, Reg, commit_state


struct SimDelay:
    var d: Reg[Bits[8]]

    def __init__(out self):
        self.d = Reg[Bits[8]]()

    def process(mut self, din: Bits[8]) -> Bits[8]:
        self.d.next(2) <= din
        return self.d.get()

    def step(mut self, din: Bits[8]) -> Bits[8]:
        var y = self.process(din)
        commit_state(self)
        return y.copy()


def main():
    var sim = SimDelay()
    print("s0", sim.step(Bits[8](1)).to_int())
    print("s1", sim.step(Bits[8](2)).to_int())
    print(
        "s2",
        sim.step(Bits[8](3)).to_int(),
        sim.d.get().to_int(),
        sim.d.past(1).to_int(),
        sim.d.past(2).to_int(),
    )
    print(
        "s3",
        sim.step(Bits[8](4)).to_int(),
        sim.d.get().to_int(),
        sim.d.past(1).to_int(),
        sim.d.past(2).to_int(),
    )
