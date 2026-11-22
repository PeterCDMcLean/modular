"""A clock-enabled write followed by a differently-conditioned write."""

from hdl import Bits


@module
struct MixedEnable:
    var value: Bits[8]

    def __init__(out self):
        self.value = Bits[8](0)

    def run(mut self, en: Bool, other: Bool) -> Bits[8]:
        if en:
            self.value = self.value + Bits[8](1)
        if other:
            self.value = self.value + Bits[8](2)
        return self.value.copy()


@module
struct NestedMixedEnable:
    var value: Bits[8]

    def __init__(out self):
        self.value = Bits[8](0)

    def run(mut self, en: Bool, mode: Bool, other: Bool) -> Bits[8]:
        if en:
            self.value = self.value + Bits[8](1)
        if mode:
            if other:
                self.value = self.value + Bits[8](3)
        return self.value.copy()
