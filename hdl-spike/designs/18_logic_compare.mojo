"""X/Z-aware Logic[W] comparisons produce a 4-state Logic[1]."""

from hdl import Logic


@module
struct LogicCompare:
    def eq(self, a: Logic[8], b: Logic[8]) -> Logic[1]:
        return a == b

    def ne(self, x: Logic[8], y: Logic[8]) -> Logic[1]:
        return x != y
