"""Packed element access: Packed.__getitem__/__setitem__ on the flat i32."""

from hdl import Bits, Packed


@module
struct PackedGet:
    def run(mut self, p: Packed[Bits[8], 4], i: Int) -> Bits[8]:
        return p[i]


@module
struct PackedSet:
    def run(
        mut self, p: Packed[Bits[8], 4], i: Int, v: Bits[8]
    ) -> Packed[Bits[8], 4]:
        var q = p.copy()
        q[i] = v
        return q.copy()
