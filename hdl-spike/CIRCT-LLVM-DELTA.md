# CIRCT HEAD × LLVM `a17069fe` → `6941494e`: fast-forward compatibility analysis

Read-only static analysis. Nothing outside this file was modified; no git
working tree was checked out or reset.

| | |
|---|---|
| CIRCT | `/home/pmclean/circt` @ `76eec00fe` (2026-11-02) |
| CIRCT gitlink | `llvm` = `a17069fea5b271c6824ea773874b007116de9644` (2026-10-08) |
| Target LLVM | `6941494e2ae550d753728ba13454311b344d82cf` (2026-10-15, Mojo pin) |
| Ancestry | `a17069fe` is an ancestor of `6941494e` (fast-forward possible) |
| Verdict | **trivial patches (1 file, ~4 lines)** |

---

## 1. Counts

Measured with `git -C /home/pmclean/circt/llvm diff a17069fe 6941494e`:

| Metric | Count |
|---|---|
| Commits in delta | **1,243** |
| Files changed (whole LLVM+MLIR) | 5,480 (+412,071 / −169,193) |
| Commits touching `mlir/` | 87 |
| Commits touching `llvm/include/` | 125 |
| Commits touching `llvm/lib/` | 509 |
| Changed files under `mlir/include/` | **45** (7 added/deleted) |
| Changed files under `llvm/include/` | **141** (5 added/deleted) |
| Changed `.td` files (MLIR) | **19** |
| Changed `.td` files (LLVM) | **11** |
| Changed headers CIRCT actually `#include`s | **9** |
| CIRCT translation units including ≥1 of those 9 | 58 |
| CIRCT TUs needing a patch | **2** (both fixed by one 4-line change, see §4) |

### 1.1 The relevance filter does almost all the work

CIRCT includes only these LLVM trees (via
`grep -rhoE '#include "llvm/[A-Za-z]+/' lib include tools`):

| LLVM subtree | CIRCT direct includes | Changed headers in delta |
|---|---|---|
| `llvm/ADT` | 697 | **0** |
| `llvm/Support` | 538 | 8 |
| `llvm/TableGen` | 30 | 1 (`Record.h`) |
| `llvm/IR` | 8 (`Module.h`, `LLVMContext.h`, `DerivedTypes.h`, `DataLayout.h`) | 18 |
| `llvm/TargetParser` | 2 (`Triple.h`, `Host.h`) | 5 |
| `llvm/Analysis`, `CodeGen`, `Transforms`, `MC`, `Passes`, `ExecutionEngine`, `ProfileData`, `DebugInfo`, `SandboxIR`, `Frontend`, `DWARFLinker`, `ABI`, `Option`, `llvm-c`, `AsmParser` | **0** | ~100 (irrelevant) |

**`llvm/include/llvm/ADT` is completely untouched in this delta**, and MLIR's
core-API headers are untouched too:

| MLIR header dir | Changed |
|---|---|
| `mlir/include/mlir/IR` (`OpBase.td`, `AttrTypeBase.td`, `TypeBase.td`, `EnumAttr.td`, `OpDefinition.h`, `Builders.h`, `Operation.h`, …) | **0** |
| `mlir/include/mlir/TableGen` (mlir-tblgen generators) | **0** |
| `mlir/include/mlir/Pass` (`Pass.h`, `PassBase.td`) | **0** |
| `mlir/include/mlir/Transforms` (`DialectConversion.h`, `GreedyPatternRewriteDriver.h`) | **0** |
| `mlir/include/mlir/Dialect/{Func,Arith,SCF,ControlFlow}` | **0** |
| `mlir/lib/IR` | 1 file (`AffineExpr.cpp`) |
| `mlir/lib/Pass`, `mlir/lib/Support`, `mlir/lib/Parser`, `mlir/lib/Bytecode` | **0** |

So no TableGen-op-definition drift, no builder/rewriter/conversion-API drift,
no pass-manager drift. That is the single strongest signal in this report: the
API surface `hw`/`comb`/`seq`/`sv`/`ExportVerilog` is built on is frozen in
this window.

## 2. The 9 changed headers CIRCT includes

Counts are "CIRCT TUs that include the header directly".

| Header | TUs | Net change | Breaking? |
|---|---|---|---|
| `llvm/Support/CommandLine.h` | 24 | `cl::LibraryOptions` internals refactored; per-context `parseCommandLineOptions` added | no (§3 item 5) |
| `mlir/Support/LLVM.h` | 19 (251 via `circt/Support/LLVM.h`) | **`mlir::MapVector` alias + fwd-decl added** | **YES** (§4) |
| `llvm/TableGen/Record.h` | 9 | `RecordKeeper::getDefs()/getClasses()` change type; `RecordVal::addReferenceLoc/getReferenceLocs` removed; `Resolver` gained virtuals | no for CIRCT (§3 items 2–4) |
| `mlir/Interfaces/DataLayoutInterfaces.h` | 4 | `DataLayout::getTypeAllocSize()` added | no (additive) |
| `llvm/Support/Allocator.h` | 3 | `SpecificBumpPtrAllocator::operator=` now calls `DestroyAll()` | no (leak fix; CIRCT only has members) |
| `llvm/InitializePasses.h` | 3 | `initializeMachineFunctionSplitterPass` removed | no (symbol unused) |
| `llvm/IR/LLVMContext.h` | 2 | `getLibraryOptions()` added | no (additive) |
| `mlir/Bindings/Python/IRCore.h` | 1 | remark-engine Python API added | no (additive) |
| `llvm/TargetParser/Triple.h` | 1 | `ARMSubArch_v9_8a` enum value | no (additive) |

Everything else in the 141 `llvm/include` and 45 `mlir/include` files is either
(i) a subtree CIRCT never includes, or (ii) additive.

## 3. Suspect-change table (full)

Severity: **blocker** / **likely patch** / **cosmetic**.

| # | LLVM commit | File | What changed | CIRCT usage | Severity |
|---|---|---|---|---|---|
| 1 | `145af0deae5` `[mlir][ArmSME] Make tile allocation order deterministic` | `mlir/include/mlir/Support/LLVM.h` | Adds `llvm::MapVector` fwd-decl **and** `mlir::MapVector` alias template | `circt::MapVector` is a *using-declaration for `llvm::MapVector`* (`include/circt/Support/LLVM.h:74-96`), so `using namespace mlir; using namespace circt;` now makes unqualified `MapVector` **ambiguous** | **likely patch (1 file)** — see §4 |
| 2 | `80017ba18d8` `TableGen: Store classes and defs in a StringMap` | `llvm/include/llvm/TableGen/Record.h` | `RecordKeeper::getDefs()/getClasses()` return `ArrayRef<const Record*>` instead of `const RecordMap&` (`std::map`) | CIRCT's backends consume `const RecordKeeper&` but only call `getAllDerivedDefinitions` (`tools/circt-tblgen/*.cpp`); no `getDefs()/getClasses()` anywhere in `lib/ include/ tools/` | cosmetic (source-breaking for other downstreams, not CIRCT) |
| 3 | `f4095d22e38` `TableGen: Move value reference locations into Record` | same | `RecordVal::addReferenceLoc()` / `RecordVal::getReferenceLocs()` **removed** | no uses (`grep -rn addReferenceLoc\|getReferenceLocs lib include tools` → empty) | cosmetic |
| 4 | `6a6c90e1182` `TableGen: Pack the RecordVal used flag…`, `c4488bc4e80`, `489d100099c`, `b4effb25802` | same | `RecordVal` layout, `Init::isTriviallyResolved`, `Resolver` caching virtuals | pure additions to `Record.h`; CIRCT only reads `RecordVal::getValue()/getType()/isTemplateArg()` | cosmetic |
| 5 | `d7316136bc3` `[Support][IR] Set library options per LLVMContext` | `llvm/include/llvm/Support/CommandLine.h` | `LibraryOptions::parse()` is now `virtual Error parse(void*, ArrayRef<const char*>, unsigned&, BumpPtrAllocator&)`; adds `global()`, `copyGlobal()`, protected ctor | `cl::ParseCommandLineOptions(argc, argv, …)` (24 tools) is unchanged; CIRCT has **no** `cl::LibraryOptions` subclass (`grep -rn LibraryOptions` → empty) | cosmetic |
| 6 | `79005f6c561`, `90a26c2feee`, `7159ce54c43`, `2b35fb9283a` `[DebugInfo]/[IR] Remove …dead debug intrinsic handling` | `llvm/IR/IntrinsicInst.h`, `llvm/IR/BasicBlock.h`, `llvm/IR/Instruction.h` | Removes `DbgVariableIntrinsic::{location_ops,replaceVariableLocationOp,addVariableLocationOps,setVariable,setRawLocation,setKillLocation,getFragment*,getValues}`, all `DbgAssignIntrinsic` setters, `DbgLabelInst::setLabel`, `skipDebugIntrinsics()`, `Instruction::isDebugOrPseudoInst()` | CIRCT never touches LLVM debug intrinsics (`grep -rn "DbgVariableIntrinsic\|skipDebugIntrinsics\|isDebugOrPseudoInst"` → empty). These headers are only reachable transitively through `llvm/IR/Module.h` (4 TUs) | cosmetic |
| 7 | `337d9d5c7f4` `[CodeGen] Merge MachineFunctionSplitter…` | `llvm/InitializePasses.h` | removes `initializeMachineFunctionSplitterPass` | `InitializePasses.h` is included by `tools/{arcilator,circt-lec,circt-bmc}` but they only call `llvm::initializeCodeGen()` | cosmetic |
| 8 | `cd9c8d090c1` `[Alignment] Add a static function to construct Align from power-of-2` | `llvm/Support/Alignment.h` | `Align::fromLog2()` added; private `Align(FromShiftValue, uint8_t)` removed | only `Align(1ULL << n)`-style public ctors are used; `Align::Constant<>()`, `value()`, `encode()/decode()` unchanged | cosmetic |
| 9 | `2d97a34c0ff`, `a0957bb89e3` `[MLIR][LLVM] Add range / noundef metadata to llvm.load` | `mlir/include/mlir/Dialect/LLVMIR/LLVMOps.{td,h}`, `LLVMInterfaces.{td,h}` | `LLVM::LoadOp` gains `noundef` + `range`; **C++ builder gains `bool isNoundef` in the middle of the parameter list** (after `isInvariantGroup`); new `RangeOpInterface` with a verifier | CIRCT calls `LLVM::LoadOp::create(b, [loc,] type, addr)` only — `grep -A4 'LLVM::LoadOp::create\|replaceOpWithNewOp<LLVM::LoadOp>' \| grep -c 'getAlignment\|getOrdering'` → **0** call sites pass the positional tail | cosmetic (a future 9-arg call would be a compile error, not silent UB) |
| 10 | `cb75841164c` `[mlir][LLVM] Verify llvm.invoke callees like llvm.call` | `LLVMOps.td` (`SymbolUserOpInterface` added to `llvm.invoke`) | stricter verifier | `grep -rn LLVM::InvokeOp` → empty; CIRCT emits no `llvm.invoke` | cosmetic |
| 11 | `14915087431` `[mlir][LLVM] Add ignore_denormal_mode UnitAttr to LLVM::AtomicRMWOp` | `LLVMOps.td`, `LLVMOpBase.td` | new attr + builder tail param | `grep -rn LLVM::AtomicRMWOp` → empty | cosmetic |
| 12 | `8719e1932a8` `[mlir][DataLayout] Add getTypeAllocSize` | `mlir/Interfaces/DataLayoutInterfaces.h` | new public method | CIRCT only *implements* `DataLayoutTypeInterface` (`lib/Conversion/MooreToCore/MooreToCore.cpp:1066`); no name clash | cosmetic |
| 13 | `a8036869bcc` `[mlir][MemorySlotInterfaces] Rename elemType→valueType` | — | **not in the delta** (the commit is an ancestor of `a17069fe`); `MemorySlotInterfaces.h`/`.td` are byte-identical between the two commits | CIRCT includes `mlir/Interfaces/MemorySlotInterfaces.td` — unaffected | cosmetic |
| 14 | `mlir/lib/Conversion/ArithCommon` → `ArithAttrToLLVM` | `mlir/include/mlir/Conversion/ArithAttrToLLVM/AttrToLLVMConverter.h` (renamed) | header + CMake lib renamed | `grep -rn AttrToLLVMConverter\|MLIRArithCommon` → empty | cosmetic |
| 15 | scf/arith/cf/memref fixes (`fa1e20e8ad8`, `15106899301`, `a5a17c547af`, `64e0b842f10`, `0de9d9a7639`, `2f13592fb1d`, `75f06bc6f80`, `22e8050bc47`, …) | `mlir/lib/Dialect/{SCF,Arith,ControlFlow,MemRef}/*.cpp` | folder/verifier/trip-count behaviour only; new errors: `scf.forall` range-arg count, `scf.for` zero step | headers unchanged ⇒ no compile impact; only canonicalisation-output churn in tests that exercise scf/arith (CIRCT's `hw/comb/seq/sv` do not) | cosmetic (test churn risk) |
| 16 | `d8b7bd11529` `[mlir][inliner] Skip first-round use recompute` | `mlir/lib/Transforms/Utils/Inliner.cpp` | perf only | — | cosmetic |
| 17 | `MLIRArithCommon`-style CMake churn; `mlir/include/mlir/Dialect/Math/TransformOps` (new), `LLVM_HAVE_MLIR_LOWERING_*` removed from flang, TargetParser `.td` renames (`ARM.td` → `AArch64TargetParserDef.td`) | CMake only | CIRCT is a standalone out-of-tree build (`find_package(MLIR REQUIRED CONFIG)`, `MLIR_DIR=/home/pmclean/circt/llvm/build/lib/cmake/mlir`) and links no renamed target | none | cosmetic |
| 18 | XeGPU/SPIRV/OpenACC/OpenMP/NVVM/Vector `.td` changes (dialect-local) | `mlir/include/mlir/Dialect/{XeGPU,SPIRV,OpenACC,OpenMP,LLVMIR/NVVM,Vector}/*.td` | dialect-local | CIRCT's `.td` files include exactly 26 distinct MLIR `.td` files — `mlir/IR/{OpBase,AttrTypeBase,EnumAttr,DialectBase,BuiltinAttributes,BuiltinTypes,BuiltinTypeInterfaces,BuiltinAttributeInterfaces,CommonAttrConstraints,CommonTypeConstraints,Interfaces,OpAsmInterface,PatternBase,Properties,RegionKindInterface,SymbolInterfaces}.td`, `mlir/Interfaces/{CallInterfaces,ControlFlowInterfaces,FunctionInterfaces,InferIntRangeInterface,InferTypeOpInterface,MemorySlotInterfaces,SideEffectInterfaces}.td`, `mlir/Pass/PassBase.td`, `mlir/Rewrite/PassUtil.td`, `mlir/Dialect/EmitC/IR/EmitCTypes.td` — **none of which changed**; no LLVM dialect `.td` is included | cosmetic |

## 4. The one real break: `mlir::MapVector` vs `circt::MapVector`

`mlir/include/mlir/Support/LLVM.h` (commit `145af0deae5`, which explicitly says
"*adds the forward declaration of `MapVector` in `mlir/Support/LLVM.h` to avoid
the prefix `llvm::`*") now contains:

```cpp
namespace mlir {
template <typename KeyT, typename ValueT, typename MapType, typename VectorType, unsigned N>
class MapVector;                                    // fwd decl
...
template <typename KeyT, typename ValueT, typename MapType = DenseMap<KeyT, unsigned>,
          typename VectorType = llvm::SmallVector<std::pair<KeyT, ValueT>, 0>, unsigned N = 0>
using MapVector = llvm::MapVector<KeyT, ValueT, MapType, VectorType, N>;
}
```

CIRCT's `include/circt/Support/LLVM.h` deliberately imports the *LLVM* entity:

```cpp
namespace llvm { ... class MapVector; ... }   // lines 75-77
namespace circt { using llvm::MapVector; }    // line 91
```

A class template (via using-declaration) and an alias template are *different
entities*, so in any scope that has both `using namespace mlir;` and
`using namespace circt;` (or `using namespace llvm;`), unqualified `MapVector`
becomes ambiguous (§[namespace.udir]/6). 251 CIRCT TUs include
`circt/Support/LLVM.h`.

The same commit adds *only* `MapVector`; `SmallMapVector`, `SmallDenseMap`,
`SmallSet`, `SmallSetVector` and `SetVector` are not added to
`mlir/Support/LLVM.h`, and `SmallMapVector`/`SmallDenseMap` are imported from
`llvm::` by CIRCT, so there is no second instance of this clash.

This was verified with the real headers, not just a mock (the only overlay is
the two headers from the target commits):

```bash
# overlay: new mlir/Support/LLVM.h (6941494e) + llvm/ADT/MapVector.h (a17069fe)
clang++ -std=c++17 -fsyntax-only -I<overlay> -I/home/pmclean/circt/include ... mv.cpp
#   error: reference to 'MapVector' is ambiguous
#          candidate found by name lookup is 'mlir::MapVector'
#          candidate found by name lookup is 'circt::MapVector'
# with `namespace circt { using mlir::MapVector; }` instead  ->  compiles clean
```

### 4.1 Affected translation units

All 26 unqualified `MapVector<…>` use sites in 12 files were classified. Files
inside `namespace circt::…` are safe (the enclosing namespace's
using-declaration is found before any using-directive). Exactly **two** TUs sit
at global scope with both using-directives:

| File | Line | Code | Container |
|---|---|---|---|
| `lib/Dialect/FIRRTL/FIRRTLReductions.cpp` | 2476 | `MapVector<StringAttr, InstanceGroup> instanceGroups;` (anonymous namespace opened at :199; `using namespace mlir/circt/firrtl` at :36-38) | `--firrtl-reduce` (not needed for `circt-opt`, but compiled into `CIRCTFIRRTL`) |
| `lib/Target/DebugInfo/EmitHGLDD.cpp` | 990 | `MapVector<StringAttr, FileEmitter> groups;` (`Emitter::Emitter`, `using namespace mlir/circt/debug` at :29-31) | firtool debug-info emission |

Safe sites (for the record): `lib/Dialect/RTG/Transforms/ElaborationPass.cpp`
(`circt::rtg`), `lib/Dialect/Arc/Transforms/{OutlineArcs,SplitFuncs}.cpp`
(`circt::arc`), `tools/domaintool/ClockSpecJSONHandler.cpp` (`circt::handlers`);
`lib/Conversion/SeqToSV/{SeqToSV,FirMemLowering,LowerFirMem}.cpp`,
`lib/Conversion/ConvertToArcs/ConvertToArcs.cpp`,
`lib/Conversion/ImportVerilog/CaptureAnalysis.cpp`,
`lib/Dialect/FIRRTL/Transforms/FullReset.cpp` are unambiguous only because they
have no `using namespace mlir;` – they should still be re-checked if that ever
changes.

### 4.2 Patch (choose one)

**A. Minimal, 2 lines** (qualify the two sites):

```cpp
llvm::MapVector<StringAttr, InstanceGroup> instanceGroups;   // FIRRTLReductions.cpp:2476
llvm::MapVector<StringAttr, FileEmitter> groups;             // EmitHGLDD.cpp:990
```
(add `#include "llvm/ADT/MapVector.h"` if the complete type isn't already
visible).

**B. Preferred, 1 file** — follow the file's own stated policy ("*it is
important to import the MLIR version, and not the LLVM version*"):
in `include/circt/Support/LLVM.h` drop the `llvm::MapVector` forward
declaration (lines 75-77) and the `using llvm::MapVector;` (line 91), and add
`using mlir::MapVector;` to the `mlir` import block at lines 38-69.

This is type-identical: `llvm::MapVector`'s defaults are
`DenseMap<KeyT,unsigned>` / `SmallVector<std::pair<KeyT,ValueT>,0>` / `N=0`,
exactly what MLIR's alias uses, so no container/ABI change. Verified to make
the ambiguity disappear (`mv_fixed.cpp` above).

## 5. Verdict

> **Trivial patches — 1 file, ~4 lines (or 2 one-line qualifications).**

No LLVM/MLIR API that `hw`, `comb`, `seq`, `sv` or `ExportVerilog` actually call
was removed or changed incompatibly in the 1,243-commit delta. The only
blocking issue is a new *name* in `mlir/Support/LLVM.h` colliding with a
using-declaration in `include/circt/Support/LLVM.h`.

Expected residual risk after the patch: **lit-test churn only**, and limited to
tests that exercise `scf`/`arith`/`memref` folding (new SCF verifier messages,
arith folding fixes), not to Verilog emission.

## 6. Recommended next step

1. **Patch first** (§4.2 option B) in a scratch branch — no CIRCT source change
   is needed beyond `include/circt/Support/LLVM.h`.
2. Point the gitlink at Mojo's LLVM and sync the submodule:
   ```bash
   git -C /home/pmclean/circt update-index --cacheinfo 160000,6941494e2ae550d753728ba13454311b344d82cf,llvm
   git -C /home/pmclean/circt submodule update --init --recursive
   ```
   (or `git -C /home/pmclean/circt/llvm checkout 6941494e` for a local spike
   without touching the gitlink).
3. **Rebuild LLVM+MLIR** in the existing build tree — CIRCT is configured
   standalone against it
   (`LLVM_DIR=/home/pmclean/circt/llvm/build/lib/cmake/llvm`,
   `MLIR_DIR=/home/pmclean/circt/llvm/build/lib/cmake/mlir`, Ninja,
   `RelWithDebInfo`, `clang++`):
   ```bash
   cmake --build /home/pmclean/circt/llvm/build --target mlir-tblgen llvm-tblgen -j3
   cmake --build /home/pmclean/circt/llvm/build -j3        # libMLIR*/libLLVM*
   ```
   Note: that build tree was configured from the *older* checkout (see §7), so a
   fresh `cmake -G Ninja -DLLVM_ENABLE_PROJECTS=mlir …` in a new directory is
   likely faster than coaxing the stale one; CIRCT only needs `MLIR_DIR` /
   `LLVM_DIR` to point at the new one.
4. **Build CIRCT incrementally, tablegen first** — `circt-tblgen` is the fastest
   possible check of the `llvm/TableGen/Record.h` changes (item 2/3/4 in §3):
   ```bash
   cmake --build /home/pmclean/circt/build --target circt-tblgen -j3
   cmake --build /home/pmclean/circt/build --target circt-opt  -j3
   cmake --build /home/pmclean/circt/build --target firtool    -j3
   ```
5. **Lit tests, in this order** (cheapest signal first). Per-directory CMake
   targets already exist in `/home/pmclean/circt/build`:
   ```bash
   B=/home/pmclean/circt/build
   # a) LLVM-dialect emission paths — most exposed to LLVMOps.td drift
   cmake --build $B --target check-circt-dialect-sim check-circt-conversion-arctollvm
   # b) the four target dialects   (28 + 11 + 17 + 21 tests)
   cmake --build $B --target check-circt-dialect-hw check-circt-dialect-comb \
                            check-circt-dialect-seq check-circt-dialect-sv
   # c) the real payload
   cmake --build $B --target check-circt-conversion-seqtosv
   cmake --build $B --target check-circt-conversion-exportverilog   # 50 tests
   # or directly: $B/bin/llvm-lit -sv /home/pmclean/circt/test/Dialect/SV
   ```
   (55 `test/Dialect/Arc` tests and the whole `test/Dialect/FIRRTL` suite are
   worth one run once `firtool` builds.)

## 7. What I could *not* determine statically

* **No end-to-end compile check was possible.** The LLVM checkout at
  `/home/pmclean/circt/llvm` is at `c2ddaaa4255` (2025-11-17) — *not* the
  recorded gitlink; its tree disagrees with `a17069fe` (e.g. `MapVector` there
  has 4 template parameters, 5 at `a17069fe`), and the clone is shallow
  (`--is-shallow-repository` → true; `c2ddaaa4..a17069fe` = 41,315 commits,
  `a17069fe..c2ddaaa4` = 9,995), so exact ancestry cannot be stated. Both
  `/home/pmclean/circt/llvm/build` and
  `/home/pmclean/circt/build` hold generated headers that no longer match the
  CIRCT sources (e.g. `build/include/circt/Dialect/HW/HWOpInterfaces.h.inc`
  references a `verifyInnerSymAttr` overload that no longer exists). A
  `-fsyntax-only` run against that tree fails for reasons unrelated to this
  delta, so it cannot be used as a baseline. The `MapVector` break was instead
  proven with the *real* target headers in isolation (§4).
* Three behavioural areas are only statically assessed as "should be fine": the
  new `scf.for`/`scf.forall` verifier checks, the `arith` folding fixes
  (`a5a17c547af`, `64e0b842f10`, `0de9d9a7639`), and the inliner change
  (`d8b7bd11529`; CIRCT uses `PatternRewriter::inlineBlockBefore`, which is
  unchanged) — a lit run is the only real test.
* I did not attempt to build `firtool`'s Slang frontend (C++20, separate
  toolchain settings, `frontends/`); its exposure to this delta is
  `llvm/Support/{Path,JSON,FileSystem}.h`, which are unchanged apart from
  `Allocator.h`.
* Full `check-circt` was out of scope; only the per-directory test lists above
  are recommended.

## 8. Reproduction

```bash
# commits
git -C /home/pmclean/circt/llvm log --oneline a17069fe..6941494e | wc -l          # 1243
git -C /home/pmclean/circt/llvm diff --stat a17069fe 6941494e | tail -1
# changed public headers
git -C /home/pmclean/circt/llvm diff --name-only a17069fe 6941494e -- mlir/include llvm/include
# which of them CIRCT includes
cd /home/pmclean/circt
for f in $(git -C llvm diff --name-only a17069fe 6941494e -- llvm/include mlir/include); do
  p=${f#llvm/include/}; p=${p#mlir/include/}
  n=$(grep -rl -F "#include \"$p\"" lib include tools | wc -l)
  [ "$n" -gt 0 ] && echo "$n $f"
done | sort -rn
# unqualified MapVector users
grep -rn "MapVector" lib include tools | grep -v "llvm::MapVector"
```
