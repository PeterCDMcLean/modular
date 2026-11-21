"""Synchronous memory helper.

`Mem[T, N]` is a convenience wrapper over `Array[Reg[T], N]`, an array of N
registers. It adds addressed access only:

* `read(i)` selects the current value of element `i`;
* `write(i, v, en)` drives element `i`'s clocked update under `en`.

The compiler may lower the array as per-entry registers or infer a RAM where
the access pattern is unambiguous. `Mem` itself is not a distinct hardware
kind.
"""

from std.collections import Array

from .hdl_type import HdlType
from .reg import Reg


struct Mem[T: HdlType & Deinitable & Defaultable, N: Int = 4](
    Copyable, Defaultable, Movable
):
    """A synchronous-write, combinational-read memory over `Array[Reg[T], N]`."""

    var data: Array[Reg[Self.T], Self.N]
    """The N register slots."""

    def __init__(out self):
        """Constructs N zeroed entries."""
        self.data = Array[Reg[Self.T], Self.N]()

    def __init__(out self, fill: Int):
        """Constructs N entries initialized to `fill`."""
        self.data = Array[Reg[Self.T], Self.N](fill=Reg[Self.T](fill))

    def __init__(out self, *values: Int):
        """Constructs N entries from a sequence of constants."""
        self.data = Array[Reg[Self.T], Self.N]()
        for i in range(Self.N):
            if i < len(values):
                self.data[i] = Reg[Self.T](values[i])
            else:
                self.data[i] = Reg[Self.T]()

    def __init__(out self, var data: Array[Reg[Self.T], Self.N]):
        """Constructs from an existing register array."""
        self.data = data^

    def __copyinit__(out self, other: Self):
        """Copies every entry."""
        self.data = other.data.copy()

    def copy(self) -> Self:
        """Returns a copy."""
        return Mem[Self.T, Self.N](self.data.copy())

    def write(mut self, index: Int, value: Self.T, enable: Bool = True):
        """Writes `value` at `index` when `enable`."""
        if enable:
            var element = self.data[index].copy()
            element.next(value)
            self.data[index] = element^

    def read(self, index: Int) -> Self.T:
        """Reads the current value at `index`."""
        return self.data[index].get()
