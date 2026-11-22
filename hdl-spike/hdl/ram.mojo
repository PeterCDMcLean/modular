"""Explicit RAM helper.

`Ram[T, N]` is a `Mem[T, N]` marked for explicit memory lowering. The compiler
emits a `seq.hlmem` with read/write ports; the SystemVerilog backend lowers it
to a real memory array. It is sugar over `Mem`, which is itself sugar over
`Array[Reg[T], N]`.
"""

from .hdl_type import HdlType
from .mem import Mem
from .sim import SimState


struct Ram[T: HdlType & Deinitable & Defaultable, N: Int = 4](
    Copyable, Defaultable, Movable, SimState
):
    """A synchronous memory that lowers through `seq.hlmem`."""

    var mem: Mem[Self.T, Self.N]
    """The register-array storage."""

    def __init__(out self):
        """Constructs N zeroed entries."""
        self.mem = Mem[Self.T, Self.N]()

    def __init__(out self, fill: Int):
        """Constructs N entries initialized to `fill`."""
        self.mem = Mem[Self.T, Self.N](fill)

    def __init__(out self, *values: Int):
        """Constructs N entries from a sequence of constants."""
        self.mem = Mem[Self.T, Self.N](*values)

    def __copyinit__(out self, other: Self):
        """Copies every entry."""
        self.mem = other.mem.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        var result = Ram[Self.T, Self.N]()
        result.mem = self.mem.copy()
        return result^

    def write(mut self, index: Int, value: Self.T, enable: Bool = True):
        """Writes `value` at `index` when `enable`."""
        self.mem.write(index, value, enable)

    def read(self, index: Int) -> Self.T:
        """Reads the current value at `index`."""
        return self.mem.read(index)

    def commit(mut self):
        """Commits the memory state."""
        self.mem.commit()
