"""MojoHDL prototype surface.

`Bits[W]` is the 2-state leaf (bitlib-backed); `Logic[W]` is the 4-state layer
above it. `Sig[T]` is a marker read by the compiler pass.
"""

comptime Sig[T: AnyType] = T

from .bits import Bits, mux
from .logic import Logic, XMode, bit, logic, mux_logic


struct ResetStyle[style: Int = 0](Copyable, Movable):
    """Ambient reset configuration for a `@module` struct.

    The compiler reads this field's `style` parameter:

    * 0: synchronous, active-high (`rst`)
    * 1: synchronous, active-low (`rst_n`)
    * 2: asynchronous, active-high (`rst`)
    * 3: asynchronous, active-low (`rst_n`)

    The field itself has no hardware representation.
    """

    def __init__(out self):
        pass
