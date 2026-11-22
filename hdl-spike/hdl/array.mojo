"""MojoHDL fixed-size array state.

`Array[T, N]` wraps the native fixed-size `std.collections.Array` and conforms
to `SimState`, so domain-level simulation commits every element once. The
surface keeps the `Array[Reg[T], N]` spelling used by the HDL designs.
"""

from std.collections import Array as StdArray

from .sim import SimState, commit_state


struct Array[T: Copyable & Defaultable & Deinitable, N: Int = 4](
    Copyable, Defaultable, Movable, SimState
):
    """A fixed-size array of hardware values or register/module elements."""

    var data: StdArray[Self.T, Self.N]
    """The underlying fixed-size storage."""

    def __init__(out self):
        """Constructs `N` default values."""
        self.data = StdArray[Self.T, Self.N]()

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

    def __setitem__(mut self, index: Int, var value: Self.T):
        """Stores `value` at element `index`."""
        self.data[index] = value^

    def commit(mut self):
        """Commits every element once."""
        for i in range(Self.N):
            var element = self.data[i].copy()
            commit_state(element)
            self.data[i] = element^
