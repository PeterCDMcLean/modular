"""Bits[W] lowering: a constant single-bit select goes to comb.extract."""

from hdl import Bits


@module
struct BitSelect:
    def run(self, a: Bits[12]) -> Bool:
        return a.bit(3)
