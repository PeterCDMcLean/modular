"""Bare register arrays: `Array[Reg[T], N]` is state; `Mem` is sugar over it."""

from hdl import Bits, Logic, Reg
from std.collections import Array


@module
struct BareArray:
    var mem: Array[Reg[Bits[8]], 4]

    def __init__(out self):
        self.mem = Array[Reg[Bits[8]], 4]()

    def run(mut self, addr: Int, wd: Bits[8], we: Bool) -> Bits[8]:
        if we:
            self.mem[addr].next(1) <= wd
        return self.mem[addr].get()


@module
struct StaticArray:
    var mem: Array[Reg[Bits[8]], 2]

    def __init__(out self):
        self.mem = Array[Reg[Bits[8]], 2]()

    def run(mut self, wd: Bits[8], we: Bool) -> Bits[8]:
        if we:
            self.mem[0].next(1) <= wd
        return self.mem[1].get()


@module
struct LogicArray:
    var mem: Array[Reg[Logic[8]], 2]

    def __init__(out self):
        self.mem = Array[Reg[Logic[8]], 2]()

    def run(mut self, addr: Int, wd: Logic[8], we: Bool) -> Logic[8]:
        if we:
            self.mem[addr].next(1) <= wd
        return self.mem[addr].get()
