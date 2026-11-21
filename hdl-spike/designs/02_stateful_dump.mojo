"""Stage 1 dump target: a `@module` struct with state and two methods.

It is not lowered yet (Stage 4 adds `Reg`). The point is to inspect the
post-elaboration KGEN IR for field access, method symbols, and argument names.
"""

from hdl import Sig


@module
struct Stateful:
    var count: Int

    def __init__(out self):
        self.count = 0

    def run(self, en: Sig[Bool]) -> Sig[Int]:
        var next = self.count
        if en:
            next = next + 1
        return next
