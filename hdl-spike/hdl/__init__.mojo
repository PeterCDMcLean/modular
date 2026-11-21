"""MojoHDL prototype surface.

`Bits[W]` is the 2-state leaf (bitlib-backed); `Logic[W]` is the 4-state layer
above it. `Sig[T]` is a marker read by the compiler pass.
"""

comptime Sig[T: AnyType] = T

from .bits import Bits, mux
from .logic import Logic, XMode, bit, logic, mux_logic
