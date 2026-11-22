"""Multiple domains with distinct stateful child instances."""

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
struct TwoDomainChildren:
    var a: ChildCounter
    var b: ChildCounter

    def __init__(out self):
        self.a = ChildCounter()
        self.b = ChildCounter()

    def run_a(mut self, en_a: Bool) -> Bits[8]:
        return self.a.run(en_a)

    def run_b(mut self, en_b: Bool) -> Bits[8]:
        return self.b.run(en_b)
