"""4-state Packed[Logic[8],4]: parallel value/mask lanes."""

from hdl import Logic, Packed, Reg


@module
struct LogicPackedGet:
    def run(mut self, p: Packed[Logic[8], 4], i: Int) -> Logic[8]:
        return p[i]


@module
struct LogicPackedPass:
    def run(
        mut self, p: Packed[Logic[8], 4], i: Int, v: Logic[8]
    ) -> Packed[Logic[8], 4]:
        var q = p.copy()
        q[i] = v
        return q.copy()


@module
struct LogicPackedReg:
    var r: Reg[Packed[Logic[8], 4]]

    def __init__(out self):
        self.r = Reg[Packed[Logic[8], 4]]()

    def run(mut self, din: Packed[Logic[8], 4]) -> Packed[Logic[8], 4]:
        self.r.next(1) <= din
        return self.r.get()
