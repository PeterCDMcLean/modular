"""Logic[W] 4-state lowering: value and X/Z mask through comb logic."""

from hdl import Logic, mux_logic


@module
struct LogicOps:
    def run(self, c: Logic[1], a: Logic[8], b: Logic[8]) -> Logic[8]:
        return mux_logic(c, ~((a & b) | (a ^ b)), a)
