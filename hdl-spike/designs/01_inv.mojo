from hdl import Sig


@module
struct Inv:
    def run(self, a: Sig[Bool]) -> Sig[Bool]:
        var y = not a
        return y
