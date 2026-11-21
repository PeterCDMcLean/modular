"""Combinational internal signal.

`Wire[W]` is a `Bits[W]` field that lowers to a combinational SSA net rather
than a register. Assignments in a process define the net; reads use the
current definition.
"""

from .bits import Bits


struct Wire[W: Int = 8](Copyable, Movable):
    """A combinational `Bits[W]` signal."""

    var inner: Bits[Self.W]
    """The driven value."""

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
        """Copies the value."""
        self.inner = other.inner.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Wire[Self.W](self.inner.copy())

    def get(self) -> Bits[Self.W]:
        """Returns the driven bits."""
        return self.inner.copy()
