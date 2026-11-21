"""Reset styles: sync/async x active-high/low selected by a config field."""

from hdl import Bits, ResetStyle


@module
struct SyncLowCounter:
    var rst_style: ResetStyle[1]
    var count: Bits[8]

    def __init__(out self):
        self.rst_style = ResetStyle[1]()
        self.count = Bits[8](1)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct AsyncHighCounter:
    var rst_style: ResetStyle[2]
    var count: Bits[8]

    def __init__(out self):
        self.rst_style = ResetStyle[2]()
        self.count = Bits[8](2)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct AsyncLowCounter:
    var rst_style: ResetStyle[3]
    var count: Bits[8]

    def __init__(out self):
        self.rst_style = ResetStyle[3]()
        self.count = Bits[8](3)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct ResetTop:
    var low: SyncLowCounter

    def __init__(out self):
        self.low = SyncLowCounter()

    def run(mut self) -> Bits[8]:
        return self.low.run()
