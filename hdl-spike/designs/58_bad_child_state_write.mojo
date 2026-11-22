"""Negative: a direct child-state write from another clock domain."""

from hdl import Bits


@module
struct ChildCounter:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct ChildWriteAcrossDomains:
    var child: ChildCounter

    def __init__(out self):
        self.child = ChildCounter()

    def run_a(mut self) -> Bits[8]:
        return self.child.run()

    def poke_b(mut self):
        self.child.count = Bits[8](5)
