"""Multiple processes: each method root gets its own clock domain."""

from hdl import Bits


@module
struct TwoDomains:
    var count_a: Bits[8]
    var count_b: Bits[8]

    def __init__(out self):
        self.count_a = Bits[8](0)
        self.count_b = Bits[8](0)

    def run_a(mut self) -> Bits[8]:
        self.count_a = self.count_a + Bits[8](1)
        return self.count_a.copy()

    def run_b(mut self) -> Bits[8]:
        self.count_b = self.count_b + Bits[8](2)
        return self.count_b.copy()
