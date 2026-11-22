//===----------------------------------------------------------------------===//
// Copyright (c) 2026, Modular Inc. All rights reserved.
//
// Licensed under the Apache License v2.0 with LLVM Exceptions:
// https://llvm.org/LICENSE.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//
//
// Prototype HDL -> CIRCT lowering.
//
// This is deliberately a small, direct pass over the elaborated KGEN IR: it
// recognizes the HDL DSL's `@module` structs and lowers them to textual
// `hw`/`comb`/`seq` operations. It lives behind `--emit=circt` and does not
// participate in the normal Mojo compilation pipeline.
//
// Two passes are provided:
//
//  * HDLCaptureNames: runs on LIT IR (before LowerLIT) and snapshots the names
//    the DSL needs for ports into module attributes. `@module` structs are
//    recorded in `hdl_modules`, and the source names of returned locals in
//    `hdl_return_names`. Both survive LowerLIT/elaboration, where the source
//    names are otherwise lost.
//
//  * HDLToCIRCT: runs after LIT lowering and builds real CIRCT hw/comb ops in
//    the module. `--emit=circt` prints them; `--emit=sv` additionally runs
//    CIRCT's seq-to-sv pass in the outer pipeline and ExportVerilog after the
//    pipeline, with no nested PassManager.
//
//===----------------------------------------------------------------------===//

#ifndef KGEN_COMPILER_PIPELINE_HDL_TO_CIRCT_H
#define KGEN_COMPILER_PIPELINE_HDL_TO_CIRCT_H

namespace llvm {
class raw_ostream;
} // namespace llvm

#include "mlir/IR/OwningOpRef.h"
#include "mlir/Support/LogicalResult.h"

#include <memory>

namespace mlir {
class Pass;
class ModuleOp;
} // namespace mlir

namespace M::KGEN {

/// Options threaded to the HDL-to-CIRCT pass by the driver.
struct HDLEmitOptions {
  /// Destination for the emitted CIRCT module. Null means `llvm::outs()`.
  llvm::raw_ostream *output = nullptr;
  /// Print the KGEN IR the pass consumed instead of lowering it. This is the
  /// Stage 1 no-op mode.
  bool dumpSourceIR = false;
  /// Export SystemVerilog through CIRCT's ExportVerilog instead of printing
  /// the MLIR module. No external `circt-opt` is involved.
  bool emitSV = false;
  /// Where the pass leaves the built module in `emitSV` mode. The driver runs
  /// seq-to-sv and ExportVerilog after the pass manager has finished, outside
  /// its execution context.
  mlir::OwningOpRef<mlir::ModuleOp> *builtModule = nullptr;
};

/// Snapshot HDL source names into module attributes before LowerLIT erases
/// them. Only runs on the `--emit=circt` path.
std::unique_ptr<mlir::Pass> createHDLCaptureNamesPass();

/// Lower `@module` structs in the elaborated KGEN module to a CIRCT module.
std::unique_ptr<mlir::Pass> createHDLToCIRCTPass(const HDLEmitOptions &options);

/// CIRCT's seq-to-sv lowering, exposed so the KGEN pipeline can run it as a
/// normal (non-nested) pass after the HDL lowering.
std::unique_ptr<mlir::Pass> createHDLSeqToSVPass();

/// Lower the array-register memory form to explicit `sv` memory ops.
mlir::LogicalResult lowerHDLArrayRegToSV(mlir::ModuleOp module);

/// Lower the `seq.hlmem` memory form to explicit `sv` memory ops.
mlir::LogicalResult lowerHDLHLMemToSV(mlir::ModuleOp module);

/// Export SystemVerilog from the already-lowered module. Runs outside any pass
/// manager execution context, which is what CIRCT's exporter expects.
mlir::LogicalResult exportHDLSystemVerilog(mlir::ModuleOp module,
                                           llvm::raw_ostream &os);

} // namespace M::KGEN

#endif // KGEN_COMPILER_PIPELINE_HDL_TO_CIRCT_H
