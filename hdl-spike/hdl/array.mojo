"""MojoHDL fixed-size array state.

`Array[T, N]` wraps the native fixed-size `std.collections.Array` and conforms
to `SimState`, so domain-level simulation commits every element once. The
surface keeps the `Array[Reg[T], N]` spelling used by the HDL designs.
"""

from std.collections import Array as StdArray

from .hdl_type import HdlType
from .sim import SimState, commit_state


def _array_element_width[T: AnyType]() -> Int:
    """The payload width of an element, or 0 for non-payload elements."""
    comptime if conforms_to(T, HdlType):
        return T.WIDTH
    return 0


struct Array[T: Copyable & Defaultable & Deinitable, N: Int = 4](
    Copyable,
    Defaultable,
    Movable,
    SimState,
    HdlType where conforms_to(T, HdlType) else (
        "Array elements must be HdlType payloads to be a hardware value"
    ),
):
    """A fixed-size array of hardware values or register/module elements.

    When `T` is an `HdlType`, the array is itself a hardware payload: its
    `WIDTH` is `N * T.WIDTH` and lanes are little-endian. Arrays of `Reg` or
    nested modules remain state containers only.
    """

    comptime WIDTH: Int = _array_element_width[Self.T]() * Self.N
    """The packed hardware width when `T` is an `HdlType`."""

    var data: StdArray[Self.T, Self.N]
    """The underlying fixed-size storage."""

    def __init__(out self):
        """Constructs `N` default values."""
        self.data = StdArray[Self.T, Self.N]()

    def __init__(out self, value: Int) where conforms_to(Self.T, HdlType):
        """Constructs from a little-endian packed integer (low 64 bits)."""
        self.data = StdArray[Self.T, Self.N]()
        for i in range(Self.N):
            var shift = i * Self.T.WIDTH
            var lane = (value >> shift) & ((1 << Self.T.WIDTH) - 1)
            self.data[i] = Self.T(lane)

    def __init__(out self, var fill: Self.T):
        """Constructs `N` copies of `fill`."""
        self.data = StdArray[Self.T, Self.N](fill=fill)

    def __init__(out self, var data: StdArray[Self.T, Self.N]):
        """Constructs from an existing native array."""
        self.data = data^

    def __copyinit__(out self, other: Self):
        """Copies every element."""
        self.data = other.data.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Array[Self.T, Self.N](self.data.copy())

    def __getitem__(ref self, index: Int, /) -> ref[origin_of(self.data)] Self.T:
        """Returns a reference to element `index`."""
        return self.data[index]

    def __setitem__(mut self, index: Int, value: Self.T):
        """Stores a copy of `value` at element `index`."""
        self.data[index] = value.copy()

    def commit(mut self):
        """Commits every element once."""
        for i in range(Self.N):
            var element = self.data[i].copy()
            commit_state(element)
            self.data[i] = element^
