"""Hierarchy: a `@module` struct field becomes an `hw.instance`."""

from hdl import Bits


@module
struct Inverter:
    def __init__(out self):
        pass

    def run(self, a: Bits[8]) -> Bits[8]:
        return ~a


@module
struct Top:
    var inv: Inverter

    def __init__(out self):
        self.inv = Inverter()

    def run(self, a: Bits[8]) -> Bits[8]:
        return self.inv.run(a)
