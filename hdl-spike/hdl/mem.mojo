"""Synchronous memory surface.

The compiler lowers `Mem` fields to an array of clock-enabled registers plus a
combinational read mux. The native implementation below provides the matching
simulation behavior.
"""

from std.collections import List

from .bits import Bits


struct Mem[W: Int = 8, N: Int = 4](Copyable, Movable):
    """A small synchronous-write, combinational-read memory."""

    var data: List[Bits[Self.W]]
    """The stored words."""

    def __init__(out self):
        """Constructs N zero words."""
        self.data = List[Bits[Self.W]]()
        for _ in range(Self.N):
            self.data.append(Bits[Self.W]())

    def write(mut self, index: Int, value: Bits[Self.W], enable: Bool = True):
        """Writes `value` at `index` when `enable`."""
        if enable:
            self.data[index] = value.copy()

    def read(self, index: Int) -> Bits[Self.W]:
        """Reads the word at `index`."""
        return self.data[index].copy()
