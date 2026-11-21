"""Per-register reset style for `Logic[W]` state.

`ResettableLogic[W, style]` carries the same style encoding as `Resettable`
(0/1 sync high/low, 2/3 async high/low) while preserving the four-state value
and X/Z mask.
"""

from .logic import Logic


struct ResettableLogic[W: Int = 8, style: Int = 0](Copyable, Movable):
    """A `Logic[W]` state value with a register-level reset style."""

    var inner: Logic[Self.W]
    """The wrapped 4-state value."""

    def __init__(out self):
        """Constructs a known zero."""
        self.inner = Logic[Self.W]()

    def __init__(out self, value: Int):
        """Constructs a known integer value."""
        self.inner = Logic[Self.W](value)

    def __init__(out self, var value: Logic[Self.W]):
        """Constructs from a Logic value."""
        self.inner = value^

    def __copyinit__(out self, other: Self):
        """Copies the wrapped value."""
        self.inner = other.inner.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return ResettableLogic[Self.W, Self.style](self.inner.copy())

    def __and__(self, other: Logic[Self.W]) -> Self:
        """Bitwise and with a Logic operand."""
        return ResettableLogic[Self.W, Self.style](self.inner & other)

    def __invert__(self) -> Self:
        """Bitwise complement."""
        return ResettableLogic[Self.W, Self.style](~self.inner)

    def get(self) -> Logic[Self.W]:
        """Returns the wrapped Logic value."""
        return self.inner.copy()
