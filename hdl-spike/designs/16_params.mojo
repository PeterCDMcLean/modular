"""Parameters/generate: one generic module specialized at two widths."""

from hdl import Bits


@module
struct ParamCounter[W: Int = 8]:
    var count: Bits[Self.W]

    def __init__(out self):
        self.count = Bits[Self.W](0)

    def run(mut self) -> Bits[Self.W]:
        self.count = self.count + Bits[Self.W](1)
        return self.count.copy()


@module
struct TwoWidths:
    var narrow: ParamCounter[8]
    var wide: ParamCounter[16]

    def __init__(out self):
        self.narrow = ParamCounter[8]()
        self.wide = ParamCounter[16]()

    def run_narrow(mut self) -> Bits[8]:
        return self.narrow.run()

    def run_wide(mut self) -> Bits[16]:
        return self.wide.run()
