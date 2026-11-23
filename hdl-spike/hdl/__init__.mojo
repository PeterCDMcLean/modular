"""MojoHDL prototype surface.

`Bits[W]` is the 2-state leaf (bitlib-backed); `Logic[W]` is the 4-state layer
above it. `Sig[T]` is a marker read by the compiler pass.
"""

comptime Sig[T: AnyType] = T

from .bits import Bits, mux
from .logic import Logic, XMode, bit, logic, mux_logic
from .mem import Mem
from .array import Array
from .array_ram import ArrayRam
from .sim import SimModule, SimState, commit_state, step
from .packed import Packed
from .ram import Ram
from .wire import Wire
from .hdl_type import HdlType
from .reg import Reg
from .param import clog2


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


struct PowerOn[value: Int = 0](Copyable, Movable):
    """Ambient power-on value for a `@module` struct's state.

    The compiler reads `value` as the initial/preset value of every state
    register, independently of the constructor-derived reset value. The field
    itself has no hardware representation.
    """

    def __init__(out self):
        pass


struct ClockDivider[pow2: Int = 1](Copyable, Movable):
    """An in-hierarchy clock source dividing the ambient clock by `pow2`.

    The compiler clocks the module's registers and child instances from
    `seq.clock_div ambient by pow2`, rooting a sub-domain inside the module.
    The field itself has no hardware representation.
    """

    def __init__(out self):
        pass
