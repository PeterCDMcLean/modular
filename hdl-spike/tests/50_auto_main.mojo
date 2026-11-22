from hdl import Bits


def main():
    var sim = AutoDomain()
    sim.din = Bits[8](1)
    AutoDomain_step(sim)
    print("c0", sim.a.get().to_int(), sim.b.get().to_int())
    sim.din = Bits[8](2)
    AutoDomain_step(sim)
    print("c1", sim.a.get().to_int(), sim.b.get().to_int())
    sim.din = Bits[8](3)
    AutoDomain_step(sim)
    print("c2", sim.a.get().to_int(), sim.b.get().to_int())
