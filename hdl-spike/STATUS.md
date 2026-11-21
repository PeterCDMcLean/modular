# Spike status

Last updated: 2026-11-21 (rebase onto current Mojo/CIRCT/LLVM pins).

## 2026-11-21 rebase (current)

| Component | Pin |
| --- | --- |
| Mojo | `4224c14a82` (`origin/main`, 2026-11-21) |
| LLVM | `eaabd239f5` (2026-11-13) |
| CIRCT upstream | `d6143d5f3` (2026-11-20) |
| CIRCT overlay | `8aa3e1913` (`bazel-overlay`, rebased onto `d6143d5f3`) |
| Mojo submodule | `third_party/circt` at `8aa3e1913` |

Build and test record:

* CIRCT subset (`HW`, `Comb`, `Seq`, `SV`, `ExportVerilog`, `SeqToSV`):
  **green**, 354.7 s, 2,026 actions, against LLVM `eaabd239f5`.
* Mojo (`//Mojo/tools/kgen:kgen`, `//Mojo/tools/mojo:mojo`, `-c dbg`,
  `--jobs=3`): **green**, 1,179.2 s, 8,590 actions.
* Mojo (`-c opt`, same targets plus `//Mojo/stdlib/std`): **green**,
  1,188.7 s, 8,639 actions.
* `hdl-spike/tests/run_all.sh`: **green** in both `-c dbg` and `-c opt`
  (00, 00b, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
  35, 36, 37, 38, 39, 40, 41). `--emit=circt` and `--emit=sv` run in-process.
* Verilator lint: skipped (not installed).
* CLI adaptation: the current compiler uses `-I <dir>`; the tests were updated
  from `-mojo-search-paths`.

## Stage table

| Stage | Status | Designs | Notes |
| --- | --- | --- | --- |
| 0. Build + `--emit=mlir` | **green** | `designs/00_hello.mojo` | `mojo build --emit=mlir` prints the compiler's own KGEN module. Hand-written CIRCT (a custom-syntax `hw.module` and a generic-syntax constant/xor fixture) parses through the compiler's own printer and re-parses with `circt-opt`. |
| 1. LIT/early-KGEN hook | **green** | `designs/01_inv.mojo`, `designs/02_stateful_dump.mojo` | Hook is after `LowerLIT`, **before** `ElaborateGenerators` (see "Insertion point"); `--emit=circt --hdl-dump-ir` prints the IR the pass consumes. |
| 2. Lower `Inv` → `hw`/`comb` | **green** | `designs/01_inv.mojo` | Emitted MLIR is byte-identical to `expected/01_inv.mlir`; the operations are real CIRCT `hw`/`comb` ops built in-process. `--emit=sv` exports SystemVerilog **in-process** through CIRCT's ExportVerilog (no `circt-opt` subprocess), matching `expected/01_inv.sv` after comment/blank-line normalization. |
| Type layer | **green (prototype)** | `hdl/bits.mojo`, `hdl/logic.mojo` | `Bits[W]` wraps bitlib's `BitInteger[W]` with stable result types; `Logic[W]` adds a 4-state value+mask. Both conform to `HdlType`, the payload trait used by generic `Reg[T]`. Native Sim tests cover add/mux/wrap and X/Z propagation (`03_sim_types`). |
| 3. Widths and arithmetic | **green (combinational)** | `designs/03_add8.mojo`, `designs/06_bits_ops.mojo`, `designs/07_bits_bit.mojo`, `designs/10_var_bit.mojo` | Primitive `UInt8` add lowers to `comb.add` (`04_add8`). The compiler now reads the *source* signature, so `Bits[W]` keeps its declared width at ports: a `Bits[12]` module lowers add/sub/and/or/xor/invert to `comb` ops (`06_bits_ops`), and `a.bit(3)` to `comb.extract` (`07_bits_bit`). A dynamic `a.bit(i)` lowers to `comb.shru` plus `comb.extract`, with the index truncated to `W` bits (`10_var_bit`). `index`/`uindex` ports map to 64-bit values. A `Bits[W]` by-ref result is recognized from the `byref_result` argument convention and written to `hw.output`. |
| Logic[W] 4-state | **green (comb + state)** | `designs/11_logic_ops.mojo`, `designs/17_logic_state.mojo`, `designs/18_logic_compare.mojo` | Each `Logic[W]` port becomes a value net plus a `<name>_xz` mask net. `&`/`\|` apply dominant known-zero/known-one rules, `^` ORs the masks, `~` keeps the mask, and `mux_logic` resolves unknown selects. A `Logic[W]` state field becomes a value register plus an X/Z mask register, with constructor constants as reset/power-on values and the same enable mux as `Bits` (`17_logic_state`). `==`/`!=` return a 4-state `Logic[1]`: a known difference yields a known false/true, any unknown bit without a known difference yields an unknown result, and only fully-known equal operands are known true (`18_logic_compare`). |
| 4. Registers/reset | **partial** | `designs/04_counter.mojo`, `designs/08_bits_counter.mojo`, `designs/09_preset_counter.mojo`, `designs/12_enable_counter.mojo`, `designs/19_reset_styles.mojo`, `designs/24_poweron.mojo`, `designs/26_resettable.mojo`, `designs/33_resettable_logic.mojo` | A primitive struct field store/load becomes `seq.compreg` (`05_counter`). `Bits[W]` fields are decoded from the source struct definition, so a `Bits[12]` counter lowers to a 12-bit register (`08_bits_counter`). Constructor constants are decoded as reset values: `self.count = Bits[12](5)` produces `seq.compreg ... reset %rst, %c5_i12` and `if (rst) q <= 12'h5;` under an ambient `rst` port (`09_preset_counter`). By default the same constant is wrapped in `seq.initial` as the power-on value, exporting as `var logic [11:0] _GEN_0 = 12'h5;`; a no-hardware `PowerOn[value]` marker overrides only the power-on/initial value, so reset and power-on can differ (`24_poweron`: reset 5, power-on 9). A conditional state update (`if en:`) becomes an input mux that holds the register when disabled (`assign _GEN = en ? q + 1 : q`), giving enable gating in combinational form (`12_enable_counter`). Reset style is selected per module by a no-hardware `ResetStyle[style]` field, or per register by `Reg[T, style]`: 0/1 are sync high/low (`seq.compreg`), 2/3 are async high/low (`seq.firreg`), and active-low domains/registers invert the ambient reset. A module can mix sync and async registers (`26_resettable`). `Reg[Logic[W], style]` provides the same per-register styles for four-state state, creating a value/mask register pair with each register's style (`33_resettable_logic`). A parent forwards and inverts reset as needed when instantiating a child of the other polarity (`19_reset_styles`). A conditional write to a sync register whose writes all share one enable becomes `seq.compreg.ce` (`else if (en)` in SV); mixed conditions or unconditional writes fall back to the input mux, and async registers keep the mux (`12_enable_counter`). |
| Parameters/generate | **green (prototype)** | `designs/16_params.mojo`, `designs/23_dependent_params.mojo`, `designs/29_param_expr.mojo` | A `@module` struct can take integer parameters used in field and port widths (`ParamCounter[W]`). Concrete binding tuples discovered from instance fields specialize the generic body (`ParamCounter_8`, `ParamCounter_16`). Multiple parameters and expressions depending on them are evaluated: `DepCounter[W, E]` uses `Bits[W + E]` and a literal `E`, producing `DepCounter_8_1` (9-bit, +1) and `DepCounter_16_4` (20-bit, +4) (`23_dependent_params`). Expressions are evaluated for additive/multiplicative forms, subtraction (`add(W, -1)`), floor/ceiling division (`apply(__floordiv__)` and `POC::Div*`), max/min/cond, and boolean conditions (`lt`, `identical`, `not`, `and/or/xor`) (`29_param_expr`). |
| Packed arrays | **green (prototype)** | `designs/39_packed.mojo` | `Packed[T, N]` wraps `Array[T, N]` and conforms to `HdlType` with `WIDTH = T.WIDTH * N`; lanes are little-endian. The pass flattens the whole value to an `iW` port/register, so `Packed[Bits[8],4]` becomes a 32-bit port and a 32-bit `seq.compreg`. Whole-value copy/move/constructor lowering works; element `get`/`set` lowering and 4-state packed arrays are not implemented yet. |
| Typed Reg | **green (prototype)** | `designs/26_resettable.mojo`, `designs/33_resettable_logic.mojo`, `designs/37_reg.mojo` | `Reg[T, style]` is a generic typed state field over any `HdlType` payload: `Reg[Bits[W], style]` is 2-state and `Reg[Logic[W], style]` is 4-state. `.next(value)` lowers to the register's clocked update (through the same enable/reset machinery as a field assignment) and `.get()` reads the current value. A constructor constant becomes its reset/power-on value (`37_reg`, `26_resettable`, `33_resettable_logic`). |
| Typed Wire | **green (prototype)** | `designs/36_wire.mojo` | `Wire[W]` is a combinational field, not state: assignments define an SSA net and reads copy it. A module containing only wires has no clock or register (`36_wire`). |
| Clock sources | **green (prototype)** | `designs/35_clock_source.mojo` | A no-hardware `ClockDivider[pow2]` field roots a sub-domain: the module's registers and child instances are clocked by `seq.clock_div ambient by pow2`. A child module can therefore root its own divided domain beneath the parent (`35_clock_source`). |
| Processes/domains | **green (prototype)** | `designs/15_two_domains.mojo`, `designs/21_bad_multi_driver.mojo`, `designs/21_bad_cross_read.mojo` | The single-method restriction is removed. Each method is a process; every stateful method root gets its own `clk_<method>`/`rst_<method>` pair, its registers are clocked by that domain, and multi-method outputs default to `<method>_out`. Writing one state field from two processes, or reading a field from a process other than its driver, is a diagnostic (`21_domain_checks`). |
| Explicit RAM | **green (prototype)** | `designs/41_ram.mojo` | `Ram[T, N]` is an explicit memory helper over `Mem`. It lowers to `seq.hlmem` plus `seq.read`/`seq.write` ports, with the address truncated to `ceil(log2(N))` bits. `--emit=sv` runs a local `seq.hlmem`-to-`sv` lowering (the upstream `lib/Dialect/Seq/Transforms` rules are not built in this Bazel overlay), producing a real unpacked-array memory (`var logic [7:0] ram_0[0:3]`) with an `always_ff` write port and a combinational read. Memory contents have no reset/initialization yet; `Ram[Logic[W],N]` and nonzero read latency are rejected. |
| Bare register arrays | **green (prototype)** | `designs/40_bare_array.mojo` | `Array[Reg[T], N]` fields are N storage slots. `mem[i].next(v)` and `mem[i].get()` lower through the same array-storage helpers as `Mem`: static indices select one slot, dynamic indices use `addr == k` enables for writes and a compare/mux tree for reads. `T = Logic[W]` creates value/mask pairs. `Mem[T, N]` is sugar over this storage; the pass no longer has a Mem-specific field kind. |
| Memories | **green (prototype)** | `designs/25_mem.mojo`, `designs/27_mem_init.mojo`, `designs/28_async_mem.mojo`, `designs/30_mem_sequence.mojo`, `designs/31_mem_dual_read.mojo`, `designs/32_mem_two_writes.mojo`, `designs/34_mem_depth2.mojo`, `designs/38_logic_mem.mojo` | `Mem[T, N]` is a helper over `Array[Reg[T], N]`, an array of N typed registers. It lowers to N `seq.compreg.ce` entries plus a combinational read mux; a write drives entry `k` when `we && (addr == k)`, and a read selects the addressed entry. A constructor fill constant initializes every entry's reset and power-on (`Mem[Bits[8],4](5)`), a `PowerOn` marker overrides power-on (`27_mem_init`), and a variadic constructor initializes distinct entries for any depth (`Mem[Bits[8],4](1,2,3,4)`, `Mem[Bits[8],2](7,9)`) (`30`, `34`). Sync-style modules use `seq.compreg.ce`; async-style modules use `seq.firreg` with a per-entry input mux (`28_async_mem`). Multiple reads are independent muxes (`31_mem_dual_read`); multiple writes combine with a defined priority (later call wins) by muxing data and OR-ing per-entry enables (`32_mem_two_writes`). `T = Logic[W]` creates a value/mask register pair per entry: the value resets to the constructor constant, the mask resets to zero, and writes/reads drive both pairs; `designs/38_logic_mem.mojo` covers a four-entry 4-state memory. Packed arrays use `Packed[T,N]` (see the row above); making `Array[T,N]` itself an `HdlType` is a later revisit. |
| Hierarchy/instances | **green (prototype)** | `designs/13_hierarchy.mojo`, `designs/14_hierarchy_state.mojo`, `designs/20_multi_instance.mojo`, `designs/22_logic_child.mojo` | A struct field whose type is another `@module` becomes `hw.instance`; child inputs are wired from call operands, ambient `clk`/`rst` are forwarded to stateful children, and child outputs drive the call's result slot. Modules are built children-first. Instance names come from field names, so repeated fields of the same child type become distinct, independently wired instances (`20_multi_instance`). A `Logic[W]` child input/output is wired as a value/mask port pair (`22_logic_child`). |
| 5–10 | not started | — | — |

`tests/run_all.sh` runs 00, 00b, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11,
12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
31, 32, 33, 34, 35, 36, 37, 38, 39, 40, and 41; all pass.

**Second phase (combined CIRCT/LLVM lowering).** The compiler now builds *real*
CIRCT ops. CIRCT is a **git submodule** at `third_party/circt` pointing at the
local fork `~/circt-fork.git`, branch `bazel-overlay`, commit `506341bcb`
(upstream `76eec00fe` + the standalone Bazel overlay + the `MapVector` fix,
with its `llvm` gitlink set to `6941494e`). The overlay is a normal Bazel repo
with per-package BUILD files (`Support`, `Emit`, `HW`, `Comb`, `Seq`, `SV`,
`LTL`, `Debug`, `OM`, `Verif`, `ExportVerilog`, `SeqToSV`), not a copied tree.
It is declared in `MODULE.bazel` as

```python
local_repository(name = "circt", path = "third_party/circt")
```

so CIRCT's own repository-relative labels (`//include/...`, `//lib/...`,
`//bazel/...`) resolve inside `@circt`, while `@llvm-project` resolves through
Mojo's mapping. `Mojo/BUILD.bazel` depends on
`@circt//lib/Dialect/{Comb,HW}:circt_{comb,hw}`. The integration build took
**739 s** (338 actions, 10,249 cache hits) and all four spike tests pass.
`@circt//lib/Conversion/ExportVerilog:circt_export_verilog` and
`@circt//lib/Conversion/SeqToSV:circt_seq_to_sv` are linked, and `--emit=sv`
runs CIRCT's `LowerSeqToSV` and `ExportVerilog` in-process. The nested-pass
problem is fixed structurally: the HDL pass builds into a scratch module and
leaves it in `HDLEmitOptions::builtModule`; after the KGEN pass manager returns,
`runKGENPipeline` runs `LowerSeqToSV` in a fresh pass manager and then calls
`exportVerilog`. That is outside any pass-manager execution context, so the
`appendDialectRegistry` assertion cannot fire, and it will work unchanged when
Stage 4 introduces `seq.compreg`. `--emit=circt` keeps printing the scratch
module with CIRCT's custom assembly (printing an op attached to the KGEN module
falls back to generic form). The HDL pass
creates `hw::HWModuleOp`, `hw::ConstantOp`, `hw::OutputOp` and `comb::XorOp`;
CIRCT's own assembly printers produce the output. The expected MLIR was updated
to CIRCT's canonical spacing (`in %a : i1`). Dependencies added:
`//third_party/circt:circt_comb` to `//Mojo:Pipeline` and
`//Mojo:ToolCommon`, and `circt::hw::HWDialect` / `circt::comb::CombDialect` to
`registerAllKGENDialects`/`preloadAllKGENDialects`.

The pin fix (`using mlir::MapVector;` in `include/circt/Support/LLVM.h`) is
committed in the fork. To populate the submodule after a fresh checkout:

```bash
git submodule update --init third_party/circt
```

To repoint at a GitHub fork later, change the `url` in `.gitmodules` (currently
the local path `/home/pmclean/circt-fork.git`, chosen to avoid a public fork)
and run `git submodule sync`. The overlay's own docs are in
`third_party/circt/docs/bazel.md`, with status in
`third_party/circt/OVERLAY-STATUS.md`.

## Build record

* Compiler targets: `//Mojo/tools/kgen:kgen` and `//Mojo/tools/mojo:mojo`.
* Stdlib target needed at run time: `//Mojo/stdlib/std` (41 s, produces
  `bazel-bin/Mojo/stdlib/std/std.mojoc`).
* Command:
  `./bazelw build -c dbg //Mojo/tools/kgen:kgen //Mojo/tools/mojo:mojo --jobs=3`
* Wall time to the first working binaries:
  * cold build: **7,237 s** (failed at 10,288/10,398 on a stale `hdrs` glob —
    `HDLToCIRCT.h` was created after analysis had run);
  * incremental recovery: 333 s + 12 s + 188 s + 192 s;
  * **total ≈ 7,962 s (2 h 13 min)** on 4 cores / 7 GB with `--jobs=3`.
* Subsequent edit/rebuild cycles: 20–35 s each (one 190 s relink). The
  pipeline iteration after the first link is cheap.
* Third phase (in-process SV): the `EmitAs::SV` change rebuilt the KGEN
  pipeline and the CIRCT ExportVerilog library; a full `kgen`/`mojo` rebuild
  took ~13 min, and the stdlib `.mojoc` must be rebuilt whenever the compiler
  binary changes.
* Second phase (vendored CIRCT + combined lowering):
  * first `//third_party/circt:circt_comb` build: 880 s (includes TableGen and
    the CIRCT `Support`/`HW`/`Comb` libraries), then a 94 s relink of `kgen`
    and ~60 s to relink `mojo`;
  * disk after the combined lowering: 72 GB free.
* Disk before build (`/`): 107,575,136,256 bytes free.
* Disk after Stages 0–2 green: 79,316,934,656 bytes free.
  **≈ 28.3 GB consumed** (Bazel output base + external LLVM + sysroot).
* RAM peak stayed under ~5 GB; no OOM.

### Tool versions

| Tool | Version / location |
| --- | --- |
| CIRCT | `~/circt` at `76eec00fe23f39e66a41894e266d0acfb886d925` (2026-11-02) |
| `circt-opt` | `~/circt/build/bin/circt-opt`, reports `CIRCT 9d329a394`, `LLVM 22.0.0git` (optimized with assertions) |
| `circt-translate` | present, but **has no `--export-verilog`** in this build |
| `firtool` | present (comparison only) |
| Mojo | built from this checkout at `cb987e0e4f` |
| Mojo LLVM pin | `6941494e2ae550d753728ba13454311b344d82cf` |
| Verilator | **not installed** (`command -v verilator` is empty); SV verification is `circt-opt` + textual diff |

### CIRCT binary date vs source

The prompt warns that the binary may predate the loop-generate commit
`d568cd165`. The binary reports `CIRCT 9d329a394`, while the checkout is at
`76eec00fe` (2026-11-02), so the binary is older than the source. This does not
affect Stages 0–2 (`hw.module`, `comb.xor`, `hw.output`, `hw.constant` parse
and export fine). Stage 8 (`sv.generate.for`) must rebuild CIRCT first.

Concretely, in `~/circt`:

| Object | Value / date |
| --- | --- |
| Source checkout `HEAD` | `76eec00fe` (2026-11-02) |
| `HEAD`'s `llvm` gitlink | `a17069fe` (2026-10-08) |
| `circt-opt` binary version | `9d329a394` (2025-11-19) |
| LLVM the binary was built with | `c2ddaaa4` (2025-11-17), the commit checked out in `~/circt/llvm` |
| `sv.generate.for` commit | `d568cd165` (2026-05-07), absent from the binary |
| Mojo LLVM pin | `6941494e` (2026-10-15) |

**Is there a CIRCT sha pinning Mojo's exact LLVM revision?** No. All 295 commits
that touch the `llvm` gitlink (across every ref in `~/circt`, merges included)
were searched. They introduce 265 distinct LLVM pins; none equals `6941494e`,
and none is a descendant of it (so no CIRCT ref pins an LLVM at or after
Mojo's). The newest pin is `a17069fe` (2026-10-08), introduced 2026-10-11.
Mojo's `6941494e` is 7 days newer, and `a17069fe` is an ancestor of
`6941494e`, so CIRCT HEAD is only one week of LLVM changes behind the Mojo
pin. When linking is attempted, the two viable alignments are:

1. bump CIRCT's `llvm` submodule to `6941494e` and build CIRCT HEAD against
   Mojo's LLVM (7-day delta, may need minor CIRCT fixes), or
2. downgrade Mojo's LLVM pin to `a17069fe` (Mojo's public patches may need
   adjusting).

A third option is to wait for CIRCT's next monthly `llvm` bump and take the
sha that pins an LLVM at or after `6941494e`.

Either way the local `circt-opt` binary must be rebuilt: it is 9d329a394
(2025-11-19), over a year behind the source checkout.

## Insertion point (Stage 1)

The hook is **after `LowerLIT`, before `ElaborateGenerators`**, not after
elaboration. This is a deliberate deviation forced by the compiler's structure;
see "Ambiguities" item 3 for why. The source structure and names are what the
pass needs, and elaboration for a design with no entry point is not available
without also elaborating the whole imported stdlib.

* Pass classes, in `Mojo/lib/Compiler/Pipeline/HDLToCIRCT.cpp`:
  * `M::KGEN::HDLCaptureNamesPass` (`hdl-capture-names`) — runs first, on LIT
    IR, before `LowerLIT`. Snapshots `@module` struct names, method argument
    names (`hdl_arg_names`), and returned-local names (`hdl_return_names`) into
    module attributes. Argument and local names exist only at LIT level.
  * `M::KGEN::HDLToCIRCTPass` (`hdl-to-circt`) — runs last, after `LowerLIT`,
    and emits the textual CIRCT module.
* Pipeline wiring: `M::KGEN::populateHDLEmitPasses` in
  `Mojo/lib/Compiler/KGENCompiler.cpp`, called from
  `KGENCompiler::runKGENPipeline` when `CompilationOptions::hdlEmit` is set.
  The pipeline is `capture → buildHDLLowerLITPipeline → HDLToCIRCT`, and is run
  directly (`pm.run`) rather than through the transform cache because the pass
  prints as a side effect.
* Driver wiring:
  * `Mojo/tools/mojo/Build/mojo-build.cpp`: `--emit=mlir`, `--emit=circt`
    (`-o -` writes to stdout).
  * `Mojo/tools/kgen/kgen.cpp`: same kinds; `--hdl-dump-ir` prints the
    pre-lowering KGEN IR.
  * `MOJO_HDL_DUMP_IR=1` is the equivalent switch for `mojo build`.
* Struct marker: `@module` is accepted by the fork and stamps `hdl_module` on
  the `lit.struct.decl`; `HDLCaptureNamesPass` reads it.

### Files touched

```text
Mojo/include/Mojo/KGENDialect/KGENEnums.td          EmitAs::MLIR, EmitAs::CIRCT
Mojo/include/Mojo/ToolCommon/CompilationOptions.h   hdlEmit/hdlOutput/hdlDumpSourceIR
Mojo/lib/Target/TargetTraits.cpp                    mlir/circt emission kinds + ext
Mojo/lib/Compiler/KGENCompiler.cpp                  populateHDLEmitPasses, branch, offload cases
Mojo/lib/Compiler/Pipeline/Pipeline.{h,cpp}         buildHDLLowerLITPipeline
Mojo/lib/Compiler/Pipeline/HDLToCIRCT.{h,cpp}       new: capture + lowering passes
Mojo/lib/MojoParser/DeclResolution.cpp              accept @module (marker only)
Mojo/BUILD.bazel                                    Pipeline deps
Mojo/tools/mojo/Build/mojo-build.cpp                emit plumbing
Mojo/tools/kgen/kgen.cpp                            emit plumbing + --hdl-dump-ir
```

## Combined CIRCT/LLVM build (in progress)

`~/circt/llvm` was checked out at `6941494e` and a fresh `RelWithDebInfo`
LLVM+MLIR build is running in `~/circt/llvm/build`; when it finishes,
`circt-opt`/`firtool` are rebuilt in `~/circt/build` against the same LLVM.
Until then the end-to-end SV checks use the old `circt-opt.9d329a` binary, which
parses the new canonical IR unchanged.

## Results

```bash
MOJO=bazel-bin/Mojo/tools/mojo/mojo
PATHSPEC=bazel-bin/Mojo/stdlib/std,hdl-spike

$MOJO build --emit=circt -o hdl-spike/build/01_inv.mlir \
    -mojo-search-paths $PATHSPEC hdl-spike/designs/01_inv.mojo
```

`hdl-spike/build/01_inv.mlir`:

```mlir
hw.module @Inv(in %a: i1, out y: i1) {
  %true = hw.constant true
  %0 = comb.xor %a, %true : i1
  hw.output %0 : i1
}
```

After `circt-opt --lower-seq-to-sv` and `--export-verilog` (comments and blank
lines normalized by the test):

```systemverilog
module Inv(
  input  a,
  output y
);
  assign y = ~a;
endmodule
```

The pass lowers `not a` from its post-`LowerLIT` form
`Bool::__invert__(Bool::__bool__(a))` (`kgen.call` × 2) directly to
`hw.constant true` + `comb.xor`, without inlining the stdlib.

## Ambiguities / findings in the reference docs

These were found while implementing Stages 0–2. The docs were **not** edited.
Each has a documented workaround so the stages could proceed.

1. **`let` and `fn` are not in this compiler's syntax.** `TokenKinds.def` has
   `kw_var` but no `kw_let`, `fn` reports "'fn' has been removed; use 'def'
   instead", and parametric aliases are `comptime Sig[T: AnyType] = T` (plain
   `alias` with parameters is rejected). The stage snippets use `let`/`fn`, so
   the designs use `var`/`def` and the DSL stub uses `comptime`. This also
   matters for naming: `var` produces `lit.var.decl "<name>"`, so a returned
   local's name is capturable; a `let` would be an unnamed SSA value.
2. **Custom decorators do not exist** ("Mojo doesn't support custom
   decorators"), so `@module` cannot come from a library. The fork accepts it on
   struct declarations and stamps a marker attribute (`hdl_module`). This is the
   only parser change and it does not alter existing programs.
3. **The requested "after elaboration" hook is not usable as stated.** In this
   compiler `LowerLIT` runs before `ElaborateGenerators`, so `lit.var.decl` is
   already gone at the post-elaboration point. Worse, with symbol DCE skipped
   (necessary because the design has no entry point), `ElaborateGenerators`
   elaborates the entire imported stdlib and fails in unrelated GPU plugin code
   (`hip/hip_hostcall.mojo`). The fork therefore hooks after `LowerLIT` and
   before elaboration, and captures names in a pre-`LowerLIT` pass. Parameters
   stay symbolic, which is also the form Stage 8 needs. Stage 4+ will need a
   scoped elaboration strategy (elaborate only the design's generators or give
   the design an exported entry point).
4. **Symbols are qualified by the imported file module**: `@Inv` becomes
   `01_inv::Inv`, and methods become `01_inv::Inv::run(01_inv::Inv,::Bool)`.
   Names captured at LIT level are stored keyed by the *qualified* source
   prefix (`01_inv::Inv::run`), and the emitted `hw.module` name drops the
   qualifier (`Inv`).
5. **Argument names are only in LIT IR.** The KGEN `sourceParamList` is empty
   for these methods (`#kgen.pog_list<[]>`), and `sourceFuncTypeGenerator` also
   has an empty argument POG list. The capture pass reads the `lit.fn` POG list
   instead and stores `hdl_arg_names`.
6. **`self` is a memory pointer, not a struct value.**
   `run`'s elaborated signature is
   `(!kgen.pointer<struct<() memoryOnly>> imm_mem, !kgen.scalar<bool>) -> !kgen.scalar<bool>`.
   The pass skips argument 0 for every method and maps `!kgen.scalar<bool>` to
   `i1`.
7. **`--emit=mlir` on a design with no entry point prints an empty module.**
   The normal pipeline DCEs an unexported `@module` struct. `--emit=mlir` on
   `00_hello.mojo` is the Stage 0 check; the `@module` IR is inspected with
   `--emit=circt --hdl-dump-ir`, which runs the non-DCE HDL pipeline.
8. **`circt-opt --export-verilog` ignores `-o` in this build.** The pass emits
   Verilog to stdout while `-o` receives the pass-manager module; the test
   redirects stdout. `circt-opt` also attaches `file:line:col` locations to
   every parsed op and `ExportVerilog` prints them as trailing `//` comments;
   the test strips comments/blank lines before diffing. `circt-translate` in
   this build has no `--export-verilog` option.
9. **A source build needs explicit import paths.** There is no installed Mojo
   config, so every invocation passes
   `-mojo-search-paths bazel-bin/Mojo/stdlib/std,hdl-spike`. `mojo run` also
   needs a compiler-rt path that this environment does not provide; the normal
   pipeline was verified with `--emit=llvm` instead.
