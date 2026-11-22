"""Two Logic value/mask pairs and two Bits values across a restarting sequence."""

from hdl import Bits, Logic


@module
struct MultiCarriedSequence:
    var out_or: Logic[8]
    var out_and: Logic[8]
    var steps: Bits[8]
    var tag: Bits[8]

    def __init__(out self):
        self.out_or = Logic[8]()
        self.out_and = Logic[8]()
        self.steps = Bits[8](0)
        self.tag = Bits[8](0)

    def run(
        mut self, n: Int, m: Int, wa: Logic[8], wb: Logic[8]
    ) -> Logic[8]:
        var acc_or = wa.copy()
        var acc_and = wb.copy()
        var steps = Bits[8](0)
        var tag = Bits[8](3)
        for _ in range(n):
            acc_or = acc_or | wa.copy()
            acc_and = acc_and & wb.copy()
            steps = steps + Bits[8](1)
            tag = tag + Bits[8](2)
        for _ in range(m):
            acc_or = acc_or | wa.copy()
            acc_and = acc_and & wb.copy()
            steps = steps + Bits[8](1)
            tag = tag + Bits[8](2)
        self.out_or = acc_or.copy()
        self.out_and = acc_and.copy()
        self.steps = steps.copy()
        self.tag = tag.copy()
        return self.out_or.copy()
