"""Typed register surface.

`Reg[W]` is a state field. `.next(value)` sets the next-state input and
`.get()` reads the current value. Hardware treats `next` as a clocked update.
"""

from .bits import Bits


struct Reg[W: Int = 8](Copyable, Movable):
    """A `Bits[W]` register."""

    var inner: Bits[Self.W]
    """The stored value."""

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
        """Copies the stored value."""
        self.inner = other.inner.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Reg[Self.W](self.inner.copy())

    def next(mut self, value: Bits[Self.W]):
        """Sets the next-state value (clocked update)."""
        self.inner = value.copy()

    def get(self) -> Bits[Self.W]:
        """Reads the current value."""
        return self.inner.copy()
