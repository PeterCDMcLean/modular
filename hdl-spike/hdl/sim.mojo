"""Native simulation domain evaluation.

A `@module` design that wants native simulation conforms to `SimModule` and
implements `evaluate` to invoke its process methods for one domain traversal.
The engine calls `evaluate` once, then `commit_state` reflects over the
module's fields and commits every `SimState` field once. `Array` conforms to
`SimState`, so bare `Array[Reg[T], N]` and arrays of nested modules commit all
elements.

Mojo does not expose struct-method reflection in this toolchain, so the module
declares its process entry point explicitly. The engine owns the traversal and
the single commit; individual registers are never ticked by the harness.
"""

trait SimState:
    """A field whose state commits at the end of a domain traversal."""

    def commit(mut self):
        """Commits one cycle of state."""
        ...


trait SimModule(Deinitable):
    """A design whose process tree can be evaluated for one domain cycle."""

    def evaluate(mut self):
        """Evaluates the module's process methods once."""
        ...


def commit_state[T: AnyType](mut value: T):
    """Commits a stateful value or recursively traverses a module struct."""
    comptime if conforms_to(T, SimState):
        value.commit()
    else:
        comptime if reflect[T].is_struct():
            comptime for i in range(reflect[T].field_count()):
                commit_state(reflect[T].field_ref[i](value))


def step[M: SimModule](mut module: M):
    """Evaluates one domain traversal and commits its state once."""
    module.evaluate()
    commit_state(module)
