"""Per-register reset styles for Logic[W]: Reg[Logic[8], style]."""

from hdl import Logic, Reg


@module
struct MixedLogicReset:
    var sync_state: Reg[Logic[8], 0]
    var async_state: Reg[Logic[8], 2]

    def __init__(out self):
        self.sync_state = Reg[Logic[8], 0](3)
        self.async_state = Reg[Logic[8], 2](5)

    def sync_step(mut self, d: Logic[8]) -> Logic[8]:
        self.sync_state.next(~(self.sync_state.get() & d))
        return self.sync_state.get()

    def async_step(mut self, e: Logic[8]) -> Logic[8]:
        self.async_state.next(~(self.async_state.get() & e))
        return self.async_state.get()
