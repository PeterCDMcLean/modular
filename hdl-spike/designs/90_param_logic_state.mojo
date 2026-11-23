"""Parameterized 4-state state: Logic[W] keeps value and mask symbolic."""

from hdl import Logic


@module
struct ParamLogicState[W: Int = 8]:
    var value: Logic[Self.W]

    def __init__(out self):
        self.value = Logic[Self.W](0)

    def run(mut self, d: Logic[Self.W]) -> Logic[Self.W]:
        self.value = ~(self.value & d)
        return self.value.copy()


@module
struct ParamLogicUsers:
    var narrow: ParamLogicState[8]
    var wide: ParamLogicState[16]

    def __init__(out self):
        self.narrow = ParamLogicState[8]()
        self.wide = ParamLogicState[16]()

    def run_narrow(mut self, n: Logic[8]) -> Logic[8]:
        return self.narrow.run(n.copy())

    def run_wide(mut self, w: Logic[16]) -> Logic[16]:
        return self.wide.run(w.copy())
