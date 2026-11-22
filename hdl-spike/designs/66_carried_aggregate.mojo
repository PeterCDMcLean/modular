"""Complex carried aggregates: Array payload locals across runtime loops."""

from hdl import Array, Bits, Logic


@module
struct RuntimeArrayCarry:
    var total: Bits[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.cycles = Bits[8](0)

    def run(mut self, count: Int, wd: Bits[8]) -> Bits[8]:
        var acc = Array[Bits[8], 4](0)
        for i in range(count):
            acc[i] = wd.copy()
        self.total = acc[0].copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()


@module
struct RuntimeLogicArrayCarry:
    var total: Logic[8]
    var cycles: Bits[8]

    def __init__(out self):
        self.total = Logic[8]()
        self.cycles = Bits[8](0)

    def run(
        mut self,
        count: Int,
        init: Array[Logic[8], 4],
        wd: Logic[8],
    ) -> Logic[8]:
        var acc = init.copy()
        for i in range(count):
            acc[i] = wd.copy()
        self.total = acc[0].copy()
        self.cycles = self.cycles + Bits[8](1)
        return self.total.copy()
