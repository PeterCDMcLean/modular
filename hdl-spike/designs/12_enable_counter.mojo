"""Register enable: a conditional state assignment holds the old value."""

from hdl import Bits


@module
struct EnableCounter:
    var count: Bits[12]

    def __init__(out self):
        self.count = Bits[12](0)

    def run(mut self, en: Bool) -> Bits[12]:
        if en:
            self.count = self.count + Bits[12](1)
        return self.count.copy()
