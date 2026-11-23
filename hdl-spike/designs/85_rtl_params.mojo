"""Compile-time parameters emitted as real SystemVerilog module parameters."""

from hdl import Bits


@module
struct Passthrough[W: Int = 8]:
    def run(self, a: Bits[Self.W]) -> Bits[Self.W]:
        return a.copy()


@module
struct TwoWidths:
    var narrow: Passthrough[8]
    var wide: Passthrough[16]

    def run_narrow(self, ni: Bits[8]) -> Bits[8]:
        return self.narrow.run(ni.copy())

    def run_wide(self, wi: Bits[16]) -> Bits[16]:
        return self.wide.run(wi.copy())


@module
struct Scaled[W: Int = 8]:
    def run(self, a: Bits[Self.W + 1]) -> Bits[Self.W + 1]:
        return a.copy()


@module
struct ScaledUsers:
    var small: Scaled[8]
    var large: Scaled[16]

    def run_small(self, si: Bits[9]) -> Bits[9]:
        return self.small.run(si.copy())

    def run_large(self, li: Bits[17]) -> Bits[17]:
        return self.large.run(li.copy())
