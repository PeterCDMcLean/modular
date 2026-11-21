"""Bits[W] variable-index bit select lowers to a shift and extract."""

from hdl import Bits


@module
struct BitPick:
    def run(self, a: Bits[12], i: Int) -> Bool:
        return a.bit(i)
