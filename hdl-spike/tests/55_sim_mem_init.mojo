from hdl import ArrayRam, Bits, Ram


def main():
    var ram = Ram[Bits[8], 4](1, 2, 3, 4)
    print(
        "ram",
        ram.read(0).to_int(),
        ram.read(1).to_int(),
        ram.read(2).to_int(),
        ram.read(3).to_int(),
    )
    ram.write(1, Bits[8](9))
    print("ram_write", ram.read(1).to_int())

    var aram = ArrayRam[Bits[8], 4](5, 6, 7, 8)
    print(
        "array",
        aram.read(0).to_int(),
        aram.read(1).to_int(),
        aram.read(2).to_int(),
        aram.read(3).to_int(),
    )
    aram.write(2, Bits[8](10))
    print("array_write", aram.read(2).to_int())
