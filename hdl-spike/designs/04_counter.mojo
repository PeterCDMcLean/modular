from hdl import Sig


@module
struct Counter:
    var count: UInt8

    def __init__(out self):
        self.count = 0

    def run(mut self) -> Sig[UInt8]:
        self.count = self.count + 1
        var y = self.count
        return y
