"""Stateful parameterized module: state width and reset from a parameter."""

from hdl import Bits, Reg


@module
struct ParamAccumulator[W: Int = 8]:
    var total: Bits[Self.W]
    var held: Reg[Bits[Self.W]]

    def __init__(out self):
        self.total = Bits[Self.W](0)
        self.held = Reg[Bits[Self.W]](1)

    def run(mut self, step: Bits[Self.W]) -> Bits[Self.W]:
        self.total = self.total + step
        self.held.next(1) <= self.held.get() + Bits[Self.W](1)
        return self.total.copy() ^ self.held.get()


@module
struct ParamStateUsers:
    var narrow: ParamAccumulator[8]
    var wide: ParamAccumulator[16]

    def __init__(out self):
        self.narrow = ParamAccumulator[8]()
        self.wide = ParamAccumulator[16]()

    def run_narrow(mut self, n: Bits[8]) -> Bits[8]:
        return self.narrow.run(n.copy())

    def run_wide(mut self, w: Bits[16]) -> Bits[16]:
        return self.wide.run(w.copy())
