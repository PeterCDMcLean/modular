"""Memory initialization: constructor fill and PowerOn for Ram and ArrayRam."""

from hdl import ArrayRam, Bits, PowerOn, Ram, ResetStyle


@module
struct RamInit:
    var poweron: PowerOn[9]
    var ram: Ram[Bits[8], 4]

    def __init__(out self):
        self.poweron = PowerOn[9]()
        self.ram = Ram[Bits[8], 4](1, 2, 3, 4)

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        self.ram.write(addr, wd, we)
        return self.ram.read(addr)


@module
struct ArrayRamInit:
    var poweron: PowerOn[9]
    var ram: ArrayRam[Bits[8], 4]

    def __init__(out self):
        self.poweron = PowerOn[9]()
        self.ram = ArrayRam[Bits[8], 4](1, 2, 3, 4)

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        self.ram.write(addr, wd, we)
        return self.ram.read(addr)


@module
struct RamInitAsync:
    var rst_style: ResetStyle[2]
    var ram: Ram[Bits[8], 4]

    def __init__(out self):
        self.rst_style = ResetStyle[2]()
        self.ram = Ram[Bits[8], 4](1, 2, 3, 4)

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        self.ram.write(addr, wd, we)
        return self.ram.read(addr)


@module
struct ArrayRamInitLow:
    var rst_style: ResetStyle[3]
    var ram: ArrayRam[Bits[8], 4]

    def __init__(out self):
        self.rst_style = ResetStyle[3]()
        self.ram = ArrayRam[Bits[8], 4](1, 2, 3, 4)

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        self.ram.write(addr, wd, we)
        return self.ram.read(addr)
