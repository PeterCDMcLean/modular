"""Dynamic breaks inside nested ifs and a nested runtime loop."""

from hdl import Bits


@module
struct NestedIfBreak:
    var seen: Bits[8]
    var total: Bits[8]

    def __init__(out self):
        self.seen = Bits[8](0)
        self.total = Bits[8](0)

    def run(mut self, count: Int, a: Bool, b: Bool, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        for _ in range(count):
            acc = acc + wd.copy()
            if a:
                self.seen = self.seen + Bits[8](1)
                if b:
                    break
        self.total = acc.copy()
        return self.total.copy()


@module
struct ElseIfBreak:
    var seen: Bits[8]
    var total: Bits[8]

    def __init__(out self):
        self.seen = Bits[8](0)
        self.total = Bits[8](0)

    def run(mut self, count: Int, a: Bool, b: Bool, wd: Bits[8]) -> Bits[8]:
        var acc = Bits[8](0)
        for _ in range(count):
            if a:
                acc = acc + wd.copy()
            else:
                self.seen = self.seen + Bits[8](1)
                if b:
                    break
        self.total = acc.copy()
        return self.total.copy()


@module
struct NestedLoopBreak:
    var seen: Bits[8]
    var total: Bits[8]

    def __init__(out self):
        self.seen = Bits[8](0)
        self.total = Bits[8](0)

    def run(
        mut self, n: Int, m: Int, a: Bool, b: Bool, wd: Bits[8]
    ) -> Bits[8]:
        var acc = Bits[8](0)
        for _ in range(n):
            for _ in range(m):
                acc = acc + wd.copy()
                if a:
                    self.seen = self.seen + Bits[8](1)
                    if b:
                        break
        self.total = acc.copy()
        return self.total.copy()
