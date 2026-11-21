"""Bits[W] lowering: any-width arithmetic and bitwise ops go to hw/comb."""

from hdl import Bits


@module
struct BitsOps:
    def run(self, a: Bits[12], b: Bits[12]) -> Bits[12]:
        var y = ((a & b) ^ ~a) | ((a - b) + b)
        return y^
