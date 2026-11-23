"""Parameter-time functions taking unpacked and packed structs."""

from hdl import Bits


struct Limits:
    """Unpacked (memory-only) parameter struct."""

    var lo: Int
    var hi: Int

    def __init__(out self, lo: Int, hi: Int):
        self.lo = lo
        self.hi = hi


@fieldwise_init
struct PackedLimits(TrivialRegisterPassable):
    """Packed (register-passable) parameter struct."""

    var lo: Int
    var hi: Int


def clamp_to(x: Int, lim: Limits) -> Int:
    if x < lim.lo:
        return lim.lo
    if x > lim.hi:
        return lim.hi
    return x


def clamp_packed(x: Int, lim: PackedLimits) -> Int:
    if x < lim.lo:
        return lim.lo
    if x > lim.hi:
        return lim.hi
    return x


@module
struct ClampedUnpacked[W: Int = 8]:
    def run(
        self, a: Bits[clamp_to(Self.W, Limits(16, 64))]
    ) -> Bits[clamp_to(Self.W, Limits(16, 64))]:
        return a.copy()


@module
struct ClampedPacked[W: Int = 8]:
    def run(
        self, a: Bits[clamp_packed(Self.W, PackedLimits(4, 32))]
    ) -> Bits[clamp_packed(Self.W, PackedLimits(4, 32))]:
        return a.copy()
