"""Parameter-time SystemVerilog function lowering."""

from hdl import Bits


@module
struct MaxWidth[W: Int = 8]:
    def run(self, a: Bits[max(Self.W, 16)]) -> Bits[max(Self.W, 16)]:
        return a.copy()
