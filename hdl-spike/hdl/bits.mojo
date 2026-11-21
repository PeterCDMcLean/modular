"""Minimal MojoHDL surface for the compiler-spike stages.

The two-state leaf is `bitlib-mojo`'s `BitInteger`. `Bits[W]` wraps it with a
fixed word policy and stable result types; `Logic[W]` adds the 4-state mask
above it. `Sig[T]` is still a marker: the compiler pass reads the module
method signature to discover ports.
"""

from bitlib import BitInteger
from std.builtin.rebind import rebind_var
from std.sys import bit_width_of

from .hdl_type import HdlType


comptime WordFor[W: Int] = (
    DType.uint8
    if W <= 8
    else (
        DType.uint16
        if W <= 16
        else (DType.uint32 if W <= 32 else DType.uint64)
    )
)
"""The storage word for a `W`-bit value."""


comptime RawBits[W: Int] = BitInteger[W, WordFor[W]]
"""The bitlib leaf with a fixed word policy (default `Typical`)."""


struct Bits[W: Int = 1](Copyable, Movable, HdlType):
    """A two-state, any-width bit vector.

    The value is bitlib's `BitInteger[W]`; arithmetic wraps at `W` bits. The
    wrapper exists to hide bitlib's policy/word parameters and to keep result
    types stable (`a + b` returns `Bits[W]`, not a policy expression).
    """

    comptime WIDTH: Int = Self.W
    """The hardware width of the value."""

    var raw: RawBits[Self.W]
    """The packed leaf value."""

    def __init__(out self):
        """Constructs zero."""
        self.raw = RawBits[Self.W]()

    def __init__(out self, value: Int):
        """Constructs a value from an integer (W <= 64 in this prototype)."""
        self.raw = RawBits[Self.W]()
        self.raw.from_integral[DType.int64](Int64(value))

    def __copyinit__(out self, other: Self):
        """Copies the packed value."""
        self.raw = RawBits[Self.W]()
        self.raw.from_integral[DType.uint64](UInt64(other.to_int()))

    def to_int(self) -> Int:
        """Returns the low 64 bits as an integer (prototype helper)."""
        return Int(self.raw.to_integral[DType.int64]())

    def bit(self, index: Int) -> Bool:
        """Returns one bit."""
        return Bool(self.raw.get(index))

    def is_zero(self) -> Bool:
        """Returns whether every bit is zero."""
        return self.raw.is_zero()

    def __add__(self, other: Self) -> Self:
        """Wrapping addition at W bits."""
        var raw = self.raw + other.raw
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __sub__(self, other: Self) -> Self:
        """Wrapping subtraction at W bits."""
        var raw = self.raw - other.raw
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __and__(self, other: Self) -> Self:
        """Bitwise and."""
        var raw = self.raw & other.raw
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __or__(self, other: Self) -> Self:
        """Bitwise or."""
        var raw = self.raw | other.raw
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __xor__(self, other: Self) -> Self:
        """Bitwise xor."""
        var raw = self.raw ^ other.raw
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __invert__(self) -> Self:
        """Bitwise complement."""
        var raw = ~self.raw
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __lshift__(self, amount: Int) -> Self:
        """Left shift within W bits."""
        var raw = self.raw << amount
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __rshift__(self, amount: Int) -> Self:
        """Logical right shift within W bits."""
        var raw = self.raw >> amount
        var result = Self()
        result.raw = rebind_var[RawBits[Self.W]](raw)
        return result^

    def __eq__(self, other: Self) -> Bool:
        """Unsigned equality."""
        return self.raw == other.raw

    def __lt__(self, other: Self) -> Bool:
        """Unsigned less-than."""
        return self.raw < other.raw

    def __le__(self, other: Self) -> Bool:
        """Unsigned less-than-or-equal."""
        return self.raw <= other.raw

    def __ne__(self, other: Self) -> Bool:
        """Unsigned inequality."""
        return self.raw != other.raw

    def __gt__(self, other: Self) -> Bool:
        """Unsigned greater-than."""
        return self.raw > other.raw

    def __ge__(self, other: Self) -> Bool:
        """Unsigned greater-than-or-equal."""
        return self.raw >= other.raw


def mux[W: Int](cond: Bool, a: Bits[W], b: Bits[W]) -> Bits[W]:
    """Selects `a` when `cond`, else `b`, bit by bit."""
    var result = Bits[W]()
    for i in range(W):
        if cond:
            result.raw.set(i, a.raw.get(i))
        else:
            result.raw.set(i, b.raw.get(i))
    return result^
