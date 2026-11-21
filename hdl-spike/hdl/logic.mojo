"""4-state `Logic[W]` layer above the 2-state `Bits[W]` leaf.

The value and the X/Z mask are both `Bits[W]` (bitlib-backed). The mask is
stored even for `XMode.none` in this prototype; the final layer specializes the
zero-mask form.
"""

from .bits import Bits


# The 4-state policy: `none` is 2-state, `taint` tracks X, `ieee` also
# distinguishes Z.
__enum XMode:
    case none
    case taint
    case ieee


comptime bit[W: Int = 1] = Bits[W]
"""The 2-state specialization."""

comptime logic[W: Int = 1] = Logic[W]
"""The default 4-state specialization."""


struct Logic[W: Int = 1, xmode: XMode = XMode.taint](Copyable, Movable):
    """A 4-state bit vector: value plus an X/Z mask."""

    var val: Bits[Self.W]
    """The 0/1 value; mask bits are don't-care."""
    var xz: Bits[Self.W]
    """The unknown mask; a set bit means X (or Z in `Ieee`)."""

    def __init__(out self):
        """Constructs a known zero."""
        self.val = Bits[Self.W]()
        self.xz = Bits[Self.W]()

    def __init__(out self, value: Int):
        """Constructs a known integer value."""
        self.val = Bits[Self.W](value)
        self.xz = Bits[Self.W]()

    def __init__(out self, var val: Bits[Self.W], var xz: Bits[Self.W]):
        """Constructs from a value and an explicit mask."""
        self.val = val^
        self.xz = xz^

    def __copyinit__(out self, other: Self):
        """Copies the value and mask."""
        self.val = other.val.copy()
        self.xz = other.xz.copy()

    def is_known(self) -> Bool:
        """Returns whether every bit is known."""
        return self.xz.is_zero()

    def known(self) -> Bits[Self.W]:
        """Returns the 2-state value; unknown bits become 0."""
        return self.val.copy()

    def bit(self, index: Int) -> Bool:
        """Returns the value bit; use ``is_unknown`` for the mask."""
        return self.val.bit(index)

    def is_unknown(self, index: Int) -> Bool:
        """Returns whether one bit is unknown."""
        return self.xz.bit(index)

    def __eq__(self, other: Self) -> Logic[1, Self.xmode]:
        """4-state equality.

        A known difference is a known false; otherwise any unknown bit makes
        the result unknown; only fully-known equal operands are known true.
        """
        var differs = False
        var unknown = False
        for i in range(Self.W):
            var ax = self.xz.bit(i)
            var bx = other.xz.bit(i)
            if ax or bx:
                unknown = True
            elif self.val.bit(i) != other.val.bit(i):
                differs = True
        var result = Logic[1, Self.xmode]()
        if differs:
            result.val.raw.set(0, False)
            result.xz.raw.set(0, False)
        elif unknown:
            result.val.raw.set(0, False)
            result.xz.raw.set(0, True)
        else:
            result.val.raw.set(0, True)
            result.xz.raw.set(0, False)
        return result^

    def __ne__(self, other: Self) -> Logic[1, Self.xmode]:
        """4-state inequality, the dual of ``__eq__``."""
        var differs = False
        var unknown = False
        for i in range(Self.W):
            var ax = self.xz.bit(i)
            var bx = other.xz.bit(i)
            if ax or bx:
                unknown = True
            elif self.val.bit(i) != other.val.bit(i):
                differs = True
        var result = Logic[1, Self.xmode]()
        if differs:
            result.val.raw.set(0, True)
            result.xz.raw.set(0, False)
        elif unknown:
            result.val.raw.set(0, False)
            result.xz.raw.set(0, True)
        else:
            result.val.raw.set(0, False)
            result.xz.raw.set(0, False)
        return result^

    def __invert__(self) -> Logic[Self.W, Self.xmode]:
        """Bitwise complement; the mask is unchanged."""
        return Logic[Self.W, Self.xmode](~self.val, self.xz.copy())

    def __and__(self, other: Self) -> Logic[Self.W, Self.xmode]:
        """Bitwise and with dominant known-zero rules."""
        var val = Bits[Self.W]()
        var xz = Bits[Self.W]()
        for i in range(Self.W):
            var av = self.val.bit(i)
            var bv = other.val.bit(i)
            var ax = self.xz.bit(i)
            var bx = other.xz.bit(i)
            if (not ax and not av) or (not bx and not bv):
                val.raw.set(i, False)
                xz.raw.set(i, False)
            elif ax or bx:
                xz.raw.set(i, True)
            else:
                val.raw.set(i, av and bv)
                xz.raw.set(i, False)
        return Logic[Self.W, Self.xmode](val^, xz^)

    def __or__(self, other: Self) -> Logic[Self.W, Self.xmode]:
        """Bitwise or with dominant known-one rules."""
        var val = Bits[Self.W]()
        var xz = Bits[Self.W]()
        for i in range(Self.W):
            var av = self.val.bit(i)
            var bv = other.val.bit(i)
            var ax = self.xz.bit(i)
            var bx = other.xz.bit(i)
            if (not ax and av) or (not bx and bv):
                val.raw.set(i, True)
                xz.raw.set(i, False)
            elif ax or bx:
                xz.raw.set(i, True)
            else:
                val.raw.set(i, False)
                xz.raw.set(i, False)
        return Logic[Self.W, Self.xmode](val^, xz^)

    def __xor__(self, other: Self) -> Logic[Self.W, Self.xmode]:
        """Bitwise xor; either unknown operand makes the bit unknown."""
        var val = Bits[Self.W]()
        var xz = Bits[Self.W]()
        for i in range(Self.W):
            var ax = self.xz.bit(i)
            var bx = other.xz.bit(i)
            if ax or bx:
                xz.raw.set(i, True)
            else:
                val.raw.set(i, self.val.bit(i) != other.val.bit(i))
                xz.raw.set(i, False)
        return Logic[Self.W, Self.xmode](val^, xz^)


def mux_logic[W: Int, xmode: XMode](
    cond: Logic[1, xmode], a: Logic[W, xmode], b: Logic[W, xmode]
) -> Logic[W, xmode]:
    """Selects with a 4-state condition.

    A known condition selects directly. An unknown condition keeps a result bit
    only when both data bits are known and equal; otherwise it is X.
    """
    var result = Logic[W, xmode]()
    if cond.is_known():
        var choose_a = cond.bit(0)
        for i in range(W):
            if choose_a:
                result.val.raw.set(i, a.val.bit(i))
                result.xz.raw.set(i, a.xz.bit(i))
            else:
                result.val.raw.set(i, b.val.bit(i))
                result.xz.raw.set(i, b.xz.bit(i))
        return result^

    for i in range(W):
        var av = a.val.bit(i)
        var bv = b.val.bit(i)
        var ak = not a.xz.bit(i)
        var bk = not b.xz.bit(i)
        if ak and bk and av == bv:
            result.val.raw.set(i, av)
            result.xz.raw.set(i, False)
        else:
            result.val.raw.set(i, False)
            result.xz.raw.set(i, True)
    return result^
