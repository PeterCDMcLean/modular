"""Runtime loops inside if branches: local done gating and a branch merge."""

from hdl import Bits, Logic


@module
struct LoopInBranch:
    var loop_total: Bits[8]
    var total: Bits[8]

    def __init__(out self):
        self.loop_total = Bits[8](0)
        self.total = Bits[8](0)

    def run(
        mut self, count: Int, go: Bool, stop: Bool, wd: Bits[8]
    ) -> Bits[8]:
        var acc = Bits[8](0)
        if go:
            var i = 0
            while i < count:
                acc = acc + wd.copy()
                if stop:
                    break
                i += 1
            self.loop_total = acc.copy()
        else:
            acc = wd.copy()
        self.total = acc.copy()
        return self.total.copy()


@module
struct LogicLoopInBranch:
    var loop_total: Logic[8]
    var total: Logic[8]

    def __init__(out self):
        self.loop_total = Logic[8]()
        self.total = Logic[8]()

    def run(
        mut self, count: Int, go: Bool, stop: Bool, wd: Logic[8]
    ) -> Logic[8]:
        var acc = wd.copy()
        if go:
            var i = 0
            while i < count:
                acc = acc | wd.copy()
                if stop:
                    break
                i += 1
            self.loop_total = acc.copy()
        else:
            acc = acc & wd.copy()
        self.total = acc.copy()
        return self.total.copy()
