"""Logic[W] state: value and X/Z mask fields become two registers."""

from hdl import Logic


@module
struct LogicStateOps:
    var state: Logic[8]

    def __init__(out self):
        self.state = Logic[8](5)

    def run(mut self, d: Logic[8]) -> Logic[8]:
        self.state = ~(self.state & d)
        return self.state.copy()
