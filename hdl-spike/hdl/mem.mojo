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

    def __init__(out self, fill: Int):
        """Constructs N words initialized to `fill`."""
        self.data = List[Bits[Self.W]]()
        for _ in range(Self.N):
            self.data.append(Bits[Self.W](fill))

    def __init__(out self, a: Int, b: Int, c: Int, d: Int):
        """Constructs a four-entry memory from explicit constants."""
        self.data = List[Bits[Self.W]]()
        self.data.append(Bits[Self.W](a))
        self.data.append(Bits[Self.W](b))
        self.data.append(Bits[Self.W](c))
        self.data.append(Bits[Self.W](d))

    def write(mut self, index: Int, value: Bits[Self.W], enable: Bool = True):
        """Writes `value` at `index` when `enable`."""
        if enable:
            self.data[index] = value.copy()

    def read(self, index: Int) -> Bits[Self.W]:
        """Reads the word at `index`."""
        return self.data[index].copy()
