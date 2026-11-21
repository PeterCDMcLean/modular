"""Minimal HDL DSL surface for the compiler-spike stages.

This is not the final library design (see mojo-hdl-analysis/02-dsl-and-types.md).
Each stage adds exactly the markers the lowering pass understands:

  * Stage 2: ``Sig[T]`` names a port payload; ``@module`` marks the module
    struct. Both are markers only — the IR the compiler already builds from
    ordinary Mojo values is what gets lowered.

Note for this compiler version: parametric aliases are ``comptime``
declarations (``comptime Sig[T: AnyType] = T``), not ``alias``.
"""

# A port payload. For the CIRCT path the value is the plain Mojo value; the
# module struct's method signature tells the lowering pass which values are
# ports.
comptime Sig[T: AnyType] = T
