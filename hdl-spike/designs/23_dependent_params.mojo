"""Dependent parameters: width W+E and a literal E, specialized twice."""

from hdl import Bits


@module
struct DepCounter[W: Int = 8, E: Int = 1]:
    var count: Bits[Self.W + Self.E]

    def __init__(out self):
        self.count = Bits[Self.W + Self.E](0)

    def run(mut self) -> Bits[Self.W + Self.E]:
        self.count = self.count + Bits[Self.W + Self.E](Self.E)
        return self.count.copy()


@module
struct DepTop:
    var a: DepCounter[8, 1]
    var b: DepCounter[16, 4]

    def __init__(out self):
        self.a = DepCounter[8, 1]()
        self.b = DepCounter[16, 4]()

    def run_a(mut self) -> Bits[9]:
        return self.a.run()

    def run_b(mut self) -> Bits[20]:
        return self.b.run()
