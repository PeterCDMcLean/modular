# HDL → CIRCT compiler spike

This directory holds the prototype fork work that lowers the Mojo HDL DSL to
CIRCT `hw`/`comb`/`seq` from inside the compiler, as described in
`mojo-hdl-analysis/` (do not edit that directory; it is the reference).

The lowering is **not** a standalone text emitter. It is an MLIR pass over the
compiler's own KGEN IR, wired behind `--emit=circt`, and it builds real CIRCT
`hw`/`comb` ops. CIRCT is a git submodule at `third_party/circt` (local fork
`~/circt-fork.git`, branch `bazel-overlay`) with a standalone Bazel overlay
committed in the fork; it is consumed as `@circt` and compiled against the same
`@llvm-project` revision as Mojo, so CIRCT's own printers and verifiers produce
the output.

## Current stage

Stages 0–2 are green (see `STATUS.md` for details and open issues):

* `--emit=mlir` prints the compiler's own module.
* `--emit=circt` lowers `@module` structs to `hw.module` + `comb.*`.
* Only `Inv` (combinational `not`) is lowered.

## Build

```bash
# From the repository root.
git submodule update --init third_party/circt   # CIRCT overlay (local fork)
./bazelw build //Mojo/tools/kgen:kgen //Mojo/tools/mojo:mojo
./bazelw build //Mojo/stdlib/std          # run-time stdlib for a source build
```

Artifacts:

* `bazel-bin/Mojo/tools/kgen/kgen`
* `bazel-bin/Mojo/tools/mojo/mojo`
* `bazel-bin/Mojo/stdlib/std/std.mojoc`

## Commands

A source build has no installed Mojo config, so every invocation needs the
stdlib and DSL package on the import path:

```bash
MOJO=bazel-bin/Mojo/tools/mojo/mojo
KGEN=bazel-bin/Mojo/tools/kgen/kgen
PATHSPEC=bazel-bin/Mojo/stdlib/std,hdl-spike

# Stage 0: the compiler's own MLIR.
$MOJO build --emit=mlir -o - -mojo-search-paths $PATHSPEC \
    hdl-spike/designs/00_hello.mojo

# Stage 1: the KGEN IR the HDL pass consumes.
$KGEN --emit=circt --hdl-dump-ir \
    -I bazel-bin/Mojo/stdlib/std -I hdl-spike \
    hdl-spike/designs/01_inv.mojo

# or, through `mojo build`:
MOJO_HDL_DUMP_IR=1 $MOJO build --emit=circt -o - -mojo-search-paths $PATHSPEC \
    hdl-spike/designs/01_inv.mojo

# Stage 2: lower Inv and export SystemVerilog, entirely in-process.
$MOJO build --emit=circt -o hdl-spike/build/01_inv.mlir \
    -mojo-search-paths $PATHSPEC hdl-spike/designs/01_inv.mojo
$MOJO build --emit=sv -o hdl-spike/build/01_inv.sv \
    -mojo-search-paths $PATHSPEC hdl-spike/designs/01_inv.mojo
```

`mojo build` writes to a file by default (`<input>.mlir`); `-o -` writes the
textual products to stdout.

## Tests

```bash
hdl-spike/tests/run_all.sh
```

* `00_emit_mlir.sh` — `--emit=mlir` is the compiler's KGEN IR.
* `00b_roundtrip.sh` — hand-written CIRCT ops survive `kgen --emit=circt` and
  re-parse with `circt-opt`.
* `01_dump.sh` — the pass runs at the recorded hook and prints the pre-lowering
  KGEN IR for `Inv` and a stateful design.
* `02_inv.sh` — `Inv` → expected MLIR → expected SV (Verilator lint if
  installed).

## Layout

```text
hdl-spike/
├── README.md          # commands, current stage
├── STATUS.md          # stage table, build time/disk, failures, ambiguities
├── designs/           # .mojo DSL sources
├── expected/          # expected .mlir and .sv
├── hdl/               # minimal DSL surface (Sig; Reg/Wire in later stages)
├── hand/              # hand-written CIRCT IR for the Stage 0 round-trip
├── build/             # generated IR (gitignored in spirit)
└── tests/             # end-to-end run scripts
```
