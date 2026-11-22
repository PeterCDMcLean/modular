"""Array[T, N] as a hardware payload: ports, fields, registers, and 4-state."""

from hdl import Array, Bits, Logic, Reg


@module
struct ArrayPass:
    def run(self, a: Array[Bits[8], 4]) -> Array[Bits[8], 4]:
        return a.copy()


@module
struct ArrayElem:
    def run(self, a: Array[Bits[8], 4], i: Int) -> Bits[8]:
        return a[i].copy()


@module
struct ArrayUpdate:
    def run(
        self, a: Array[Bits[8], 4], i: Int, v: Bits[8]
    ) -> Array[Bits[8], 4]:
        var q = a.copy()
        q[i] = v.copy()
        return q.copy()


@module
struct ArrayField:
    var xs: Array[Bits[8], 4]

    def __init__(out self):
        self.xs = Array[Bits[8], 4](0x04030201)

    def run(mut self, i: Int, v: Bits[8]) -> Bits[8]:
        self.xs[i] = v.copy()
        return self.xs[0].copy()


@module
struct ArrayReg:
    var r: Reg[Array[Bits[8], 4]]

    def __init__(out self):
        self.r = Reg[Array[Bits[8], 4]]()

    def run(mut self, a: Array[Bits[8], 4]) -> Array[Bits[8], 4]:
        self.r.next(1) <= a
        return self.r.get()


@module
struct LogicArrayPass:
    def run(self, a: Array[Logic[8], 4]) -> Array[Logic[8], 4]:
        return a.copy()


@module
struct LogicArrayField:
    var xs: Array[Logic[8], 4]

    def __init__(out self):
        self.xs = Array[Logic[8], 4]()

    def run(mut self, v: Logic[8]) -> Logic[8]:
        self.xs[1] = v.copy()
        return self.xs[2].copy()
