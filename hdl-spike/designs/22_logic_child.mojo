"""Logic-port child: wire the value/mask port pair through hw.instance."""

from hdl import Logic


@module
struct LogicInverter:
    def __init__(out self):
        pass

    def run(self, a: Logic[8]) -> Logic[8]:
        return ~a


@module
struct LogicTop:
    var inv: LogicInverter

    def __init__(out self):
        self.inv = LogicInverter()

    def run(self, d: Logic[8]) -> Logic[8]:
        return self.inv.run(d)
