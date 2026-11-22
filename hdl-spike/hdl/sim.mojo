"""Native simulation domain evaluation.

A `@module` design that wants native simulation conforms to `SimModule` and
passes its process methods to the engine's `step`. The engine invokes the
registered processes in order, then `commit_state` reflects over the module's
fields and commits every `SimState` field once. `Array` conforms to
`SimState`, so bare `Array[Reg[T], N]` fields and arrays of nested modules
commit all elements.

Mojo does not expose struct-method reflection in this toolchain, so the design
registers method references when it calls `step`. The engine owns the
traversal and the single commit; individual registers are never ticked by the
harness.
"""

trait SimState:
    """A field whose state commits at the end of a domain traversal."""

    def commit(mut self):
        """Commits one cycle of state."""
        ...


trait SimModule(Deinitable):
    """A design whose process methods can be registered with the engine."""
    pass


def commit_state[T: AnyType](mut value: T):
    """Commits a stateful value or recursively traverses a module struct."""
    comptime if conforms_to(T, SimState):
        value.commit()
    else:
        comptime if reflect[T].is_struct():
            comptime for i in range(reflect[T].field_count()):
                commit_state(reflect[T].field_ref[i](value))


def step[M: SimModule](mut module: M, p1: Some[def(mut M)]):
    """Runs one registered process, then commits state once."""
    p1(module)
    commit_state(module)


def step[
    M: SimModule
](mut module: M, p1: Some[def(mut M)], p2: Some[def(mut M)]):
    """Runs two registered processes, then commits state once."""
    p1(module)
    p2(module)
    commit_state(module)


def step[
    M: SimModule
](
    mut module: M,
    p1: Some[def(mut M)],
    p2: Some[def(mut M)],
    p3: Some[def(mut M)],
):
    """Runs three registered processes, then commits state once."""
    p1(module)
    p2(module)
    p3(module)
    commit_state(module)
