"""Negative: loop-carried Logic state is not lowered yet."""

from hdl import Logic


@module
struct RuntimeLogicAccum:
    var total: Logic[8]

    def __init__(out self):
        self.total = Logic[8]()

    def run(mut self, count: Int, wd: Logic[8]) -> Logic[8]:
        var acc = wd.copy()
        for _ in range(count):
            acc = acc | wd.copy()
        self.total = acc.copy()
        return self.total.copy()
