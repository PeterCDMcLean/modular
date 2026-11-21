from hdl import Sig


@module
struct Add8:
    def run(self, a: Sig[UInt8], b: Sig[UInt8]) -> Sig[UInt8]:
        var y = a + b
        return y
