"""If/else control flow inside inlined struct methods."""

from hdl import Bits


struct Counter:
    var value: Bits[8]
    var hits: Bits[8]

    def __init__(out self, v: Bits[8]):
        self.value = v.copy()
        self.hits = Bits[8](0)

    def step(mut self, en: Bool, d: Bits[8]):
        if en:
            self.value = self.value + d.copy()
            self.hits = self.hits + Bits[8](1)
        else:
            self.value = self.value - Bits[8](1)


struct Stepper:
    var value: Bits[8]
    var count: Bits[8]

    def __init__(out self, v: Bits[8]):
        self.value = v.copy()
        self.count = Bits[8](0)

    def update(mut self, en: Bool, d: Bits[8]):
        var step = d.copy() + Bits[8](2)
        if en:
            self.value = self.value + step.copy()
            self.count = self.count + Bits[8](1)
        else:
            self.value = self.value - step.copy()


@module
struct ConditionalMethodCarry:
    var total: Bits[8]
    var hits: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.hits = Bits[8](0)

    def run(mut self, count: Int, en: Bool, wd: Bits[8]) -> Bits[8]:
        var o = Counter(wd.copy())
        for _ in range(count):
            o.step(en, wd.copy())
        self.total = o.value.copy()
        self.hits = o.hits.copy()
        return self.total.copy()


@module
struct LocalStepCarry:
    var total: Bits[8]
    var count: Bits[8]

    def __init__(out self):
        self.total = Bits[8](0)
        self.count = Bits[8](0)

    def run(mut self, count: Int, en: Bool, wd: Bits[8]) -> Bits[8]:
        var o = Stepper(wd.copy())
        for _ in range(count):
            o.update(en, wd.copy())
        self.total = o.value.copy()
        self.count = o.count.copy()
        return self.total.copy()
