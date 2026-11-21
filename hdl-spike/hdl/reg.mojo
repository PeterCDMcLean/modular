"""Typed register surface.

`Reg[T, style]` is a register over any `HdlType` payload, so the same type
covers 2-state `Bits[W]` and 4-state `Logic[W]` state. The `style` parameter
selects the register-level reset behavior:

* 0: synchronous, active-high
* 1: synchronous, active-low
* 2: asynchronous, active-high
* 3: asynchronous, active-low

`.next(value)` is the clocked update; `.get()` reads the current value.
"""

from .hdl_type import HdlType


struct Reg[T: HdlType & Deinitable & Defaultable, style: Int = 0](
    Copyable, Defaultable, Movable
):
    """A typed register over `T`."""

    var inner: Self.T
    """The stored value."""

    def __init__(out self):
        """Constructs `T`'s default value."""
        self.inner = Self.T()

    def __init__(out self, value: Int):
        """Constructs from an integer constant."""
        self.inner = Self.T(value)

    def __init__(out self, var value: Self.T):
        """Constructs from a payload value."""
        self.inner = value^

    def __copyinit__(out self, other: Self):
        """Copies the stored value."""
        self.inner = other.inner.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Reg[Self.T, Self.style](self.inner.copy())

    def next(mut self, value: Self.T):
        """Sets the next-state value (clocked update)."""
        self.inner = value.copy()

    def next(mut self, delay: Int) -> NextTarget[
        Self.T, origin_of(self), Self.style
    ]:
        """Returns a `NextTarget` for `self.next(delay) <= value`."""
        return NextTarget[Self.T, origin_of(self), Self.style](
            MutPointer[Reg[Self.T, Self.style], origin_of(self)](to=self),
            delay,
        )

    def next_delayed(mut self, delay: Int, value: Self.T):
        """Delayed update used by `NextTarget.__le__`."""
        self.inner = value.copy()

    def past(self, delay: Int) -> Self.T:
        """Returns the value `delay` cycles ago (Sim placeholder)."""
        return self.inner.copy()

    def get(self) -> Self.T:
        """Reads the current value."""
        return self.inner.copy()


struct NextTarget[
    T: HdlType & Deinitable & Defaultable,
    origin: Origin[mut=True],
    style: Int = 0,
](Movable):
    """Temporary target for `reg.next(n) <= value`."""

    var reg: MutPointer[Reg[Self.T, Self.style], Self.origin]
    """The register being updated."""

    var delay: Int
    """The number of cycles to delay the update."""

    def __init__(
        out self,
        var reg: MutPointer[Reg[Self.T, Self.style], Self.origin],
        delay: Int,
    ):
        """Constructs a delayed update target."""
        self.reg = reg
        self.delay = delay

    @always_inline
    def __le__(self, value: Self.T):
        """Schedules the delayed update."""
        self.reg[].next_delayed(self.delay, value)
