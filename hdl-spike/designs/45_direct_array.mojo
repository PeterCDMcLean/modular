"""Direct array element assignment: mem[i] = Reg[T](value)."""



from hdl import Bits, Logic, Reg, Array


@module
struct DirectArraySet:
    var mem: Array[Reg[Bits[8]], 2]

    def __init__(out self):
        self.mem = Array[Reg[Bits[8]], 2]()

    def run(mut self, i: Int, v: Bits[8]) -> Bits[8]:
        self.mem[i] = Reg[Bits[8]](v.copy())
        return self.mem[i].get()


@module
struct DirectStaticSet:
    var mem: Array[Reg[Bits[8]], 2]

    def __init__(out self):
        self.mem = Array[Reg[Bits[8]], 2]()

    def run(mut self, v: Bits[8]) -> Bits[8]:
        self.mem[0] = Reg[Bits[8]](v.copy())
        return self.mem[0].get()


@module
struct DirectLogicSet:
    var mem: Array[Reg[Logic[8]], 2]

    def __init__(out self):
        self.mem = Array[Reg[Logic[8]], 2]()

    def run(mut self, i: Int, v: Logic[8]) -> Logic[8]:
        self.mem[i] = Reg[Logic[8]](v.copy())
        return self.mem[i].get()
