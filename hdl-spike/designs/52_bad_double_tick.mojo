"""Negative: one stateful child ticked twice in one process."""

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
struct DoubleTick:
    var child: ChildCounter

    def __init__(out self):
        self.child = ChildCounter()

    def run(mut self, en: Bool) -> Bits[8]:
        var a = self.child.run(en)
        var b = self.child.run(en)
        return a ^ b
