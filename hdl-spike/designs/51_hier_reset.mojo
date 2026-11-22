"""Hierarchical reset forwarding: active-low parent, mixed child styles."""

from hdl import Bits, ResetStyle


@module
struct AsyncLowChild:
    var rst_style: ResetStyle[3]
    var count: Bits[8]

    def __init__(out self):
        self.rst_style = ResetStyle[3]()
        self.count = Bits[8](3)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct SyncHighChild:
    var count: Bits[8]

    def __init__(out self):
        self.count = Bits[8](5)

    def run(mut self) -> Bits[8]:
        self.count = self.count + Bits[8](1)
        return self.count.copy()


@module
struct ResetParentLow:
    var rst_style: ResetStyle[1]
    var a: AsyncLowChild
    var b: SyncHighChild

    def __init__(out self):
        self.rst_style = ResetStyle[1]()
        self.a = AsyncLowChild()
        self.b = SyncHighChild()

    def run(mut self) -> Bits[8]:
        return self.a.run() ^ self.b.run()


@module
struct ResetParentHigh:
    var a: AsyncLowChild
    var b: SyncHighChild

    def __init__(out self):
        self.a = AsyncLowChild()
        self.b = SyncHighChild()

    def run(mut self) -> Bits[8]:
        return self.a.run() ^ self.b.run()
