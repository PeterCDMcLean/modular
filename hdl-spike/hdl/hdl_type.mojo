"""The payload-type contract shared by hardware values.

`HdlType` is the set of values that can be stored in state and moved on a
wire. The current prototype requires a fixed `WIDTH`, a default constructor,
and a width-agnostic integer constructor so that `Reg[T]` can build reset and
zero values without knowing the concrete type.
"""

trait HdlType(Copyable, Movable):
    """A hardware payload type with a fixed bit width."""

    comptime WIDTH: Int
    """The number of bits in the value."""

    def __init__(out self):
        """Constructs the type's zero/default value."""
        ...

    def __init__(out self, value: Int):
        """Constructs a value from an integer constant."""
        ...
