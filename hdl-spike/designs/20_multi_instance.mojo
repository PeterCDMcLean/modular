"""Multiple instances: repeated child fields get distinct instances."""

from hdl import Bits


@module
struct Inverter:
    def __init__(out self):
        pass

    def run(self, a: Bits[8]) -> Bits[8]:
        return ~a


@module
struct Counter:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](0)

    def run(mut self, en: Bool) -> Bits[8]:
        if en:
            self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct MultiInstance:
    var inv_a: Inverter
    var inv_b: Inverter
    var ctr_a: Counter
    var ctr_b: Counter

    def __init__(out self):
        self.inv_a = Inverter()
        self.inv_b = Inverter()
        self.ctr_a = Counter()
        self.ctr_b = Counter()

    def run(
        mut self, a: Bits[8], b: Bits[8], en_a: Bool, en_b: Bool
    ) -> Bits[8]:
        var x = self.inv_a.run(a)
        var y = self.inv_b.run(b)
        var p = self.ctr_a.run(en_a)
        var q = self.ctr_b.run(en_b)
        return x ^ y ^ p ^ q
