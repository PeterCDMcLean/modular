"""Parameter-time function with basic if/else flow control."""

from hdl import Bits


def clamp(x: Int, lo: Int, hi: Int) -> Int:
    if x < lo:
        return lo
    if x > hi:
        return hi
    return x


@module
struct Clamped[W: Int = 8]:
    def run(self, a: Bits[clamp(Self.W, 16, 64)]) -> Bits[clamp(Self.W, 16, 64)]:
        return a.copy()
