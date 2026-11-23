"""$clog2 in parameter expressions: port widths and state widths."""

from hdl import Bits, clog2


@module
struct ClogPort[W: Int = 8]:
    def run(self, a: Bits[clog2(Self.W)]) -> Bits[clog2(Self.W)]:
        return a.copy()


@module
struct ClogCounter[W: Int = 8]:
    var count: Bits[clog2(Self.W)]

    def __init__(out self):
        self.count = Bits[clog2(Self.W)](0)

    def run(mut self) -> Bits[1]:
        self.count = self.count + Bits[clog2(Self.W)](1)
        return Bits[1](0)


@module
struct ClogTop:
    var small: ClogCounter[8]
    var large: ClogCounter[32]

    def __init__(out self):
        self.small = ClogCounter[8]()
        self.large = ClogCounter[32]()

    def run_small(mut self) -> Bits[1]:
        return self.small.run()

    def run_large(mut self) -> Bits[1]:
        return self.large.run()
