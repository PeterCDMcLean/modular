"""Parameter-time helpers that lower to SystemVerilog system functions."""


def clog2(value: Int) -> Int:
    """Ceiling log2 of a positive integer.

    Used in RTL parameter expressions; the HDL lowering emits it as
    `$clog2(value)` (and `#hw.param.expr.clog2` in the intermediate form).
    """
    var result = 0
    var remaining = value - 1
    while remaining > 0:
        result += 1
        remaining >>= 1
    return result
