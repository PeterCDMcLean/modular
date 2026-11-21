"""Packed hardware array value.

`Packed[T, N]` is a single value with `N` lanes of payload `T`. It is the
wire/port payload for an array, as opposed to `Array[Reg[T], N]`, which is N
independent state slots. The host storage is the native fixed-size
`Array[T, N]`; CIRCT sees the flattened bit pattern.

Lanes are little-endian: lane 0 occupies the least-significant `T.WIDTH` bits.
"""

from std.collections import Array

from .hdl_type import HdlType


struct Packed[T: HdlType & Defaultable & Deinitable, N: Int = 4](
    Copyable, Defaultable, Movable, HdlType
):
    """A packed array of `N` payload values."""

    comptime WIDTH: Int = Self.T.WIDTH * Self.N
    """The total hardware width of the packed value."""

    var data: Array[Self.T, Self.N]
    """The N lanes."""

    def __init__(out self):
        """Constructs N zero lanes."""
        self.data = Array[Self.T, Self.N]()

    def __init__(out self, value: Int):
        """Constructs from a little-endian packed integer.

        Only the low 64 bits are representable in this prototype.
        """
        self.data = Array[Self.T, Self.N]()
        for i in range(Self.N):
            var shift = i * Self.T.WIDTH
            var lane = (value >> shift) & ((1 << Self.T.WIDTH) - 1)
            self.data[i] = Self.T(lane)

    def __init__(out self, var data: Array[Self.T, Self.N]):
        """Constructs from an existing lane array."""
        self.data = data^

    def __copyinit__(out self, other: Self):
        """Copies every lane."""
        self.data = other.data.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Packed[Self.T, Self.N](self.data.copy())

    def __getitem__(self, index: Int) -> Self.T:
        """Returns a copy of lane `index`."""
        return self.data[index].copy()

    def __setitem__(mut self, index: Int, value: Self.T):
        """Stores a lane value at `index`."""
        self.data[index] = value.copy()
