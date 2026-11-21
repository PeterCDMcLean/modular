"""Per-register reset style wrapper.

`Resettable[W, style]` behaves like `Bits[W]` but carries the reset style used
when the compiler turns the field into a register:

* 0: synchronous, active-high
* 1: synchronous, active-low
* 2: asynchronous, active-high
* 3: asynchronous, active-low

The module's ambient reset port still follows its `ResetStyle` marker; a
register-level polarity is applied to that ambient signal.
"""

from .bits import Bits


struct Resettable[W: Int = 8, style: Int = 0](Copyable, Movable):
    """A `Bits[W]` state value with a register-level reset style."""

    var inner: Bits[Self.W]
    """The wrapped bits."""

    def __init__(out self):
        """Constructs zero."""
        self.inner = Bits[Self.W]()

    def __init__(out self, value: Int):
        """Constructs from an integer."""
        self.inner = Bits[Self.W](value)

    def __init__(out self, var value: Bits[Self.W]):
        """Constructs from a bits value."""
        self.inner = value^

    def __copyinit__(out self, other: Self):
        """Copies the wrapped value."""
        self.inner = other.inner.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Resettable[Self.W, Self.style](self.inner.copy())

    def __add__(self, other: Self) -> Self:
        """Wrapping addition."""
        var sum = self.inner + other.inner
        return Resettable[Self.W, Self.style](sum^)

    def get(self) -> Bits[Self.W]:
        """Returns the wrapped bits."""
        return self.inner.copy()
