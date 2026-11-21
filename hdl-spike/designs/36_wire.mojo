"""Typed Wire: a combinational field lowered to an SSA net."""

from hdl import Bits, Wire


@module
struct WireDemo:
    var w: Wire[8]

    def __init__(out self):
        self.w = Wire[8](0)

    def run(mut self, a: Bits[8], b: Bits[8]) -> Bits[8]:
        var x = a ^ b
        self.w = Wire[8](x^)
        return self.w.get()
