"""Parameter expressions: subtraction, floor division, and max/cond."""

from hdl import Bits


@module
struct SubMod[W: Int = 8]:
    var x: Bits[Self.W - 1]

    def __init__(out self):
        self.x = Bits[Self.W - 1](1)

    def run(mut self) -> Bits[Self.W]:
        self.x = self.x + Bits[Self.W - 1](1)
        return Bits[Self.W](0)


@module
struct DivMod[W: Int = 8]:
    var x: Bits[Self.W // 2]

    def __init__(out self):
        self.x = Bits[Self.W // 2](2)

    def run(mut self) -> Bits[Self.W]:
        self.x = self.x + Bits[Self.W // 2](1)
        return Bits[Self.W](0)


@module
struct MaxMod[W: Int = 8, E: Int = 2]:
    var x: Bits[Self.W if Self.W > Self.E else Self.E]

    def __init__(out self):
        self.x = Bits[Self.W if Self.W > Self.E else Self.E](3)

    def run(mut self) -> Bits[Self.W]:
        self.x = self.x + Bits[Self.W if Self.W > Self.E else Self.E](1)
        return Bits[Self.W](0)


@module
struct ExprTop:
    var s: SubMod[8]
    var d: DivMod[9]
    var m: MaxMod[8, 2]

    def __init__(out self):
        self.s = SubMod[8]()
        self.d = DivMod[9]()
        self.m = MaxMod[8, 2]()

    def run_s(mut self) -> Bits[8]:
        return self.s.run()

    def run_d(mut self) -> Bits[9]:
        return self.d.run()

    def run_m(mut self) -> Bits[8]:
        return self.m.run()
