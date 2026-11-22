"""Negative: one stateful child instance ticked from two domains."""

from hdl import Bits


@module
struct ChildCounter:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run(mut self, en: Bool) -> Bits[8]:
        if en:
            self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct SharedChildConflict:
    var child: ChildCounter

    def __init__(out self):
        self.child = ChildCounter()

    def run_a(mut self, en_a: Bool) -> Bits[8]:
        return self.child.run(en_a)

    def run_b(mut self, en_b: Bool) -> Bits[8]:
        return self.child.run(en_b)
