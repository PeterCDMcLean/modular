"""Logic delayed next and past: value/mask delay chains."""

from hdl import Logic, Reg


@module
struct LogicNextDelay:
    var d: Reg[Logic[8]]

    def __init__(out self):
        self.d = Reg[Logic[8]]()

    def run(mut self, din: Logic[8]) -> Logic[8]:
        self.d.next(2) <= din
        return self.d.get()


@module
struct LogicPastDelay:
    var d: Reg[Logic[8]]

    def __init__(out self):
        self.d = Reg[Logic[8]]()

    def run(mut self, din: Logic[8]) -> Logic[8]:
        self.d.next(1) <= din
        return self.d.past(2)
