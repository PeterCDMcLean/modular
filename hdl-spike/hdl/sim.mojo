"""Native simulation state traversal.

`commit_state(module)` walks a module's field tree at the end of one process
traversal and commits every stateful field exactly once. `Reg`, `Mem`, and
`Ram` conform to `SimState`; nested module structs are traversed by reflection.
A design's cycle step should evaluate its process methods first, then call
`commit_state` on the module.
"""

trait SimState:
    """A field whose state commits at the end of a domain traversal."""

    def commit(mut self):
        """Commits one cycle of state."""
        ...


def commit_state[T: AnyType](mut value: T):
    """Commits every stateful field in `value` once."""
    comptime if conforms_to(T, SimState):
        value.commit()
    else:
        comptime if reflect[T].is_struct():
            comptime for i in range(reflect[T].field_count()):
                commit_state(reflect[T].field_ref[i](value))
