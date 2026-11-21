"""In-hierarchy clock source: child sub-domain clocked by clk/2."""

from hdl import Bits, ClockDivider


@module
struct DivCounter:
    var clk_src: ClockDivider[2]
    var count: Bits[8]

    def __init__(out self):
        self.clk_src = ClockDivider[2]()
        self.count = Bits[8](0)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct ClockTop:
    var child: DivCounter

    def __init__(out self):
        self.child = DivCounter()

    def run(mut self) -> Bits[8]:
        return self.child.run()
