"""Typed register surface.

`Reg[T, style]` is a register over any `HdlType` payload, so the same type
covers 2-state `Bits[W]` and 4-state `Logic[W]` state. The `style` parameter
selects the register-level reset behavior:

* 0: synchronous, active-high
* 1: synchronous, active-low
* 2: asynchronous, active-high
* 3: asynchronous, active-low

`reg.next(n) <= value` schedules a clocked update `n` cycles ahead; `.past(n)`
reads the value `n` cycles ago. Native simulation advances cycles with
`reg.tick()`.
"""

from std.collections import Array

from .hdl_type import HdlType
from .sim import SimState


struct Reg[
    T: HdlType & Deinitable & Defaultable,
    style: Int = 0,
    max_delay: Int = 8,
](Copyable, Defaultable, Movable, SimState):
    """A typed register over `T` with native cycle history."""

    var inner: Self.T
    """The stored value."""

    var history: Array[Self.T, Self.max_delay]
    """Past values; `history[0]` is the value before the last tick."""

    var pending: Array[Self.T, Self.max_delay]
    """Scheduled next values; slot `n-1` holds a `.next(n)` update."""

    var pending_valid: Array[Bool, Self.max_delay]
    """Whether each pending slot has been scheduled."""

    def __init__(out self):
        """Constructs `T`'s default value."""
        self.inner = Self.T()
        self.history = Array[Self.T, Self.max_delay]()
        self.pending = Array[Self.T, Self.max_delay]()
        self.pending_valid = Array[Bool, Self.max_delay]()

    def __init__(out self, value: Int):
        """Constructs from an integer constant."""
        self.inner = Self.T(value)
        self.history = Array[Self.T, Self.max_delay]()
        self.pending = Array[Self.T, Self.max_delay]()
        self.pending_valid = Array[Bool, Self.max_delay]()

    def __init__(out self, var value: Self.T):
        """Constructs from a payload value."""
        self.inner = value^
        self.history = Array[Self.T, Self.max_delay]()
        self.pending = Array[Self.T, Self.max_delay]()
        self.pending_valid = Array[Bool, Self.max_delay]()

    def __copyinit__(out self, other: Self):
        """Copies the stored value and its history."""
        self.inner = other.inner.copy()
        self.history = other.history.copy()
        self.pending = other.pending.copy()
        self.pending_valid = other.pending_valid.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        var result = Self(self.inner.copy())
        result.history = self.history.copy()
        result.pending = self.pending.copy()
        result.pending_valid = self.pending_valid.copy()
        return result^

    def next(mut self, delay: Int) -> NextTarget[
        Self.T, origin_of(self), Self.style, Self.max_delay
    ]:
        """Returns a `NextTarget` for `self.next(delay) <= value`."""
        return NextTarget[
            Self.T, origin_of(self), Self.style, Self.max_delay
        ](
            MutPointer[Reg[Self.T, Self.style, Self.max_delay], origin_of(self)](
                to=self
            ),
            delay,
        )

    def next_delayed(mut self, delay: Int, value: Self.T):
        """Schedules a delayed update for the native simulator."""
        var index = delay - 1
        if index < 0:
            index = 0
        if index >= Self.max_delay:
            index = Self.max_delay - 1
        self.pending[index] = value.copy()
        self.pending_valid[index] = True

    def past(self, delay: Int) -> Self.T:
        """Returns the value `delay` cycles ago."""
        if delay <= 0:
            return self.inner.copy()
        var index = delay - 1
        if index >= Self.max_delay:
            index = Self.max_delay - 1
        return self.history[index].copy()

    def commit(mut self):
        """Commits one native-simulation cycle."""
        for i in range(1, Self.max_delay):
            self.history[Self.max_delay - i] = self.history[
                Self.max_delay - i - 1
            ].copy()
        self.history[0] = self.inner.copy()

        if self.pending_valid[0]:
            self.inner = self.pending[0].copy()

        for i in range(0, Self.max_delay - 1):
            self.pending[i] = self.pending[i + 1].copy()
            self.pending_valid[i] = self.pending_valid[i + 1]
        self.pending[Self.max_delay - 1] = Self.T()
        self.pending_valid[Self.max_delay - 1] = False

    def get(self) -> Self.T:
        """Reads the current value."""
        return self.inner.copy()


struct NextTarget[
    T: HdlType & Deinitable & Defaultable,
    origin: Origin[mut=True],
    style: Int = 0,
    max_delay: Int = 8,
](Movable):
    """Temporary target for `reg.next(n) <= value`."""

    var reg: MutPointer[Reg[Self.T, Self.style, Self.max_delay], Self.origin]
    """The register being updated."""

    var delay: Int
    """The number of cycles to delay the update."""

    def __init__(
        out self,
        var reg: MutPointer[
            Reg[Self.T, Self.style, Self.max_delay], Self.origin
        ],
        delay: Int,
    ):
        """Constructs a delayed update target."""
        self.reg = reg
        self.delay = delay

    @always_inline
    def __le__(self, value: Self.T):
        """Schedules the delayed update."""
        self.reg[].next_delayed(self.delay, value)
