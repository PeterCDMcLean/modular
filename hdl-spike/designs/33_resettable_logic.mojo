"""Per-register reset styles for Logic[W] state (sync and async)."""

from hdl import Logic, ResettableLogic


@module
struct MixedLogicReset:
    var sync_state: ResettableLogic[8, 0]
    var async_state: ResettableLogic[8, 2]

    def __init__(out self):
        self.sync_state = ResettableLogic[8, 0](3)
        self.async_state = ResettableLogic[8, 2](5)

    def sync_step(mut self, d: Logic[8]) -> Logic[8]:
        self.sync_state = ~(self.sync_state & d)
        return self.sync_state.get()

    def async_step(mut self, e: Logic[8]) -> Logic[8]:
        self.async_state = ~(self.async_state & e)
        return self.async_state.get()
