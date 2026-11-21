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
// This is deliberately a small, direct pass over the lowered KGEN IR: it
// recognizes the HDL DSL's `@module` structs and builds real CIRCT
// `hw`/`comb` ops in the compiler's own MLIR context. It lives behind
// `--emit=circt` and does not participate in the normal Mojo pipeline.
//
// Two passes are provided:
//
//  * HDLCaptureNames: runs on LIT IR (before LowerLIT) and snapshots the names
//    the DSL needs for ports into module attributes. `@module` structs are
//    recorded in `hdl_modules`, and the source names of method arguments and
//    returned locals in `hdl_arg_names` / `hdl_return_names`. Both survive
//    LowerLIT, where the source names are otherwise lost.
//
//  * HDLToCIRCT: runs after LowerLIT and builds a CIRCT `hw.module` for each
//    `@module` struct. CIRCT is vendored under `third_party/circt` and built
//    against the same LLVM revision as Mojo, so the ops are real CIRCT ops and
//    their custom printers/parsers are the upstream ones.
//
//===----------------------------------------------------------------------===//

#include "HDLToCIRCT.h"

#include "circt/Conversion/ExportVerilog.h"
#include "circt/Conversion/SeqToSV.h"

#include "circt/Dialect/Comb/CombDialect.h"
#include "circt/Dialect/Comb/CombOps.h"
#include "circt/Dialect/HW/HWDialect.h"
#include "circt/Dialect/HW/HWDialect.h"
#include "circt/Dialect/HW/HWOps.h"
#include "circt/Dialect/HW/HWTypes.h"
#include "circt/Dialect/HW/PortImplementation.h"
#include "circt/Dialect/Seq/SeqDialect.h"
#include "circt/Dialect/Seq/SeqOps.h"
#include "Mojo/KGENDialect/KGENAttrs.h"
#include "Mojo/KGENDialect/KGENDialect.h"
#include "Mojo/KGENDialect/KGENOps.h"
#include "Mojo/KGENDialect/KGENTypes.h"
#include "Mojo/LITDialect/LITDialect.h"
#include "Mojo/LITDialect/LITOps.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/raw_ostream.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"

#include <memory>
#include <optional>
#include <string>

using namespace mlir;
using namespace circt;

namespace M::KGEN {
namespace {

constexpr llvm::StringLiteral kHdlModulesAttr = "hdl_modules";
constexpr llvm::StringLiteral kHdlReturnNamesAttr = "hdl_return_names";
constexpr llvm::StringLiteral kHdlArgNamesAttr = "hdl_arg_names";
constexpr llvm::StringLiteral kHdlModuleMarker = "hdl_module";

//===----------------------------------------------------------------------===//
// HDLCaptureNames
//===----------------------------------------------------------------------===//

/// Snapshot the source names the HDL lowering needs before LowerLIT erases
/// them. This runs first in the `--emit=circt` pipeline:
///
///   * `@module` structs are recorded by symbol name in `hdl_modules`.
///   * For each module method, the argument names and the names of locals
///     returned by `return` are recorded in `hdl_arg_names` and
///     `hdl_return_names`, keyed by `Struct::method`.
class HDLCaptureNamesPass
    : public PassWrapper<HDLCaptureNamesPass, OperationPass<ModuleOp>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(HDLCaptureNamesPass)

  StringRef getArgument() const override { return "hdl-capture-names"; }
  StringRef getDescription() const override {
    return "Capture HDL port names before LIT lowering";
  }

  void runOnOperation() override;
};

/// Strip reference-only views to the underlying `lit.var.decl`, if any.
static LIT::VarDeclOp findVarDecl(Value value) {
  while (value) {
    Operation *def = value.getDefiningOp();
    if (!def)
      return {};
    if (auto varDecl = dyn_cast<LIT::VarDeclOp>(def))
      return varDecl;
    if (auto load = dyn_cast<LIT::RefLoadOp>(def)) {
      value = load.getRef();
      continue;
    }
    if (auto immut = dyn_cast<LIT::RefImmutOp>(def)) {
      value = immut.getRef();
      continue;
    }
    if (auto upcast = dyn_cast<LIT::RefUpcastOp>(def)) {
      value = upcast.getRef();
      continue;
    }
    break;
  }
  return {};
}

/// The `Struct::method` prefix of a mangled symbol like `"Inv::run(::Inv)"`.
static StringRef symbolSourcePrefix(StringRef symbol) {
  size_t end = symbol.find_first_of("(<");
  return symbol.take_front(end);
}

/// The file/package qualifier LowerLIT prepends to symbols, e.g. `01_inv` for
/// `01_inv::Inv`. Empty at the top level.
static std::string moduleQualifier(Operation *op) {
  SmallVector<StringRef> parts;
  for (Operation *parent = op->getParentOp(); parent;
       parent = parent->getParentOp()) {
    if (auto file = dyn_cast<LIT::FileModuleOp>(parent))
      parts.push_back(file.getSymName());
    else if (auto package = dyn_cast<LIT::PackageOp>(parent))
      parts.push_back(package.getSymName());
  }
  std::string result;
  for (auto it = parts.rbegin(); it != parts.rend(); ++it) {
    if (!result.empty())
      result += "::";
    result += it->str();
  }
  return result;
}

static std::string qualify(Operation *op, StringRef localName) {
  std::string qualifier = moduleQualifier(op);
  return qualifier.empty() ? localName.str()
                           : (qualifier + "::" + localName).str();
}

/// The source key of a function: `Struct::method` for methods nested in a
/// struct declaration, otherwise the flattened symbol name.
static std::string sourceFunctionKey(Operation *fn) {
  auto symbol = fn->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
  if (!symbol)
    return {};
  if (auto parent = fn->getParentOfType<LIT::StructDeclOp>())
    return qualify(fn, (parent.getSymName() + "::" + symbol.getValue()).str());
  return qualify(fn, symbol.getValue());
}

void HDLCaptureNamesPass::runOnOperation() {
  ModuleOp module = getOperation();
  MLIRContext *ctx = module.getContext();

  // 1. Structs marked `@module`.
  SmallVector<Attribute> moduleNames;
  llvm::StringSet<> moduleStructNames;
  module.walk([&](LIT::StructDeclOp decl) {
    if (decl->hasAttr(kHdlModuleMarker)) {
      std::string name = qualify(decl, decl.getSymName());
      moduleNames.push_back(StringAttr::get(ctx, name));
      moduleStructNames.insert(name);
    }
  });

  // 2. Argument and returned-local names, per module method. Methods may be
  // nested in the struct declaration or flattened to a qualified top-level
  // symbol.
  NamedAttrList returnNames;
  NamedAttrList argNames;
  llvm::StringSet<> seenKeys;
  module.walk([&](LIT::FnOp fn) {
    std::string key = sourceFunctionKey(fn);
    bool isModuleMethod = false;
    for (StringRef moduleName : moduleStructNames.keys()) {
      if (key.starts_with((moduleName + "::").str())) {
        isModuleMethod = true;
        break;
      }
    }
    if (!isModuleMethod)
      return;

    key = symbolSourcePrefix(key).str();
    if (key.empty() || !seenKeys.insert(key).second)
      return;

    SmallVector<Attribute> names;
    bool sawReturn = false;
    fn.walk([&](LIT::ReturnOp ret) {
      if (sawReturn)
        return;
      sawReturn = true;
      for (Value operand : ret.getOperands()) {
        if (auto varDecl = findVarDecl(operand))
          names.push_back(varDecl.getNameAttr());
        else
          names.push_back(StringAttr::get(ctx, ""));
      }
    });
    returnNames.append(StringAttr::get(ctx, key), ArrayAttr::get(ctx, names));

    SmallVector<Attribute> args;
    auto fnType = fn.getFuncTypeGenerator();
    auto argPogs = fnType.getBodyFnType().getArgListAttrs();
    for (const auto &pog : argPogs.getPogs())
      args.push_back(pog.getName());
    argNames.append(StringAttr::get(ctx, key), ArrayAttr::get(ctx, args));
  });

  module->setAttr(kHdlModulesAttr, ArrayAttr::get(ctx, moduleNames));
  module->setAttr(kHdlReturnNamesAttr, returnNames.getDictionary(ctx));
  module->setAttr(kHdlArgNamesAttr, argNames.getDictionary(ctx));
}

//===----------------------------------------------------------------------===//
// Type / naming helpers
//===----------------------------------------------------------------------===//

/// Return the HDL bit width of a value type, or 0 if this prototype does not
/// know how to map it.
static unsigned getBitWidth(Type type) {
  if (auto intTy = dyn_cast<IntegerType>(type))
    return intTy.getWidth();
  if (auto simdTy = dyn_cast<SIMDType>(type)) {
    auto size = simdTy.getResolvedSize();
    if (!size)
      return 0;
    auto dtype = simdTy.getResolvedDType();
    if (!dtype)
      return 0;
    // `kBool` occupies a byte in memory but is one bit on a wire.
    if (dtype->isBool())
      return static_cast<unsigned>(*size);
    if (!dtype->isInt() && !dtype->isFloat())
      return 0;
    return static_cast<unsigned>(dtype->getWidthInBits() * *size);
  }
  return 0;
}

/// Convert a DSL/KGEN value type to the integer type used by CIRCT.
static Type getHwType(Type type) {
  if (isa<IntegerType>(type))
    return type;
  unsigned width = getBitWidth(type);
  if (!width)
    return {};
  return IntegerType::get(type.getContext(), width);
}

/// Return the generator type carrier of a `kgen.func` / `kgen.generator`.
static KGEN::FuncTypeGeneratorType getFuncTypeGenerator(Operation *op) {
  if (auto gen = dyn_cast<KGEN::GeneratorOp>(op))
    return gen.getFuncTypeGenerator();
  if (auto fn = dyn_cast<KGEN::FuncOp>(op))
    return fn.getFuncTypeGenerator();
  return {};
}

/// The callee symbol of a `kgen.call`, or empty if it has none.
static StringRef callCalleeName(Operation *op) {
  auto symbol = KGEN::FuncSymbolGenerator::dynCast(op->getAttr("callee"));
  if (!symbol)
    return {};
  return symbol.getSymbol().getLeafReference().getValue();
}

/// Decode a scalar integer constant op, if this is one.
static std::optional<llvm::APInt> getConstantInt(Operation *op) {
  for (NamedAttribute attr : op->getAttrs()) {
    if (auto simd = dyn_cast<KGEN::SIMDAttr>(attr.getValue())) {
      if (simd.getValues().size() == 1)
        return simd.getValues()[0].getIntVal();
    }
    if (auto intAttr = dyn_cast<IntegerAttr>(attr.getValue()))
      return intAttr.getValue();
  }
  return std::nullopt;
}

/// Decode a scalar-bool constant op, if this is one.
static std::optional<bool> getConstantBool(Operation *op) {
  for (NamedAttribute attr : op->getAttrs()) {
    if (auto simd = dyn_cast<KGEN::SIMDAttr>(attr.getValue())) {
      if (simd.getType().getResolvedSize() == 1 &&
          simd.getType().getResolvedDType() == KGENDType::kBool)
        return simd.getAsBool();
    }
    if (auto intAttr = dyn_cast<IntegerAttr>(attr.getValue()))
      if (intAttr.getType().isInteger(1))
        return intAttr.getValue().getBoolValue();
  }
  return std::nullopt;
}

//===----------------------------------------------------------------------===//
// HDLToCIRCT
//===----------------------------------------------------------------------===//

/// Emits one `hw.module` per `@module` struct by building real CIRCT ops.
class CirctModuleEmitter {
public:
  CirctModuleEmitter(ModuleOp source, StringRef structName, ModuleOp scratch)
      : source(source), structName(structName), scratch(scratch),
        builder(scratch.getContext()), loc(scratch.getLoc()) {}

  LogicalResult build();
  hw::HWModuleOp getModule() const { return builtModule; }

private:
  struct Port {
    std::string name;
    unsigned width;
    bool isInput;
  };

  LogicalResult collectPorts();
  LogicalResult findMethods();
  LogicalResult emitOps(Operation *fn, Value &returnValue);
  LogicalResult emitOp(Operation *op, Value &returnValue);
  Value getValue(Value value);
  Value getConstant(bool value);
  Value getOrCreateReg(unsigned fieldIndex, Type type);

  ModuleOp source;
  StringRef structName;
  ModuleOp scratch;
  OpBuilder builder;

  SmallVector<Port> ports;
  SmallVector<Operation *> methods;

  DenseMap<Value, Value> values;
  DenseMap<Value, unsigned> fieldPtrs;
  DenseMap<unsigned, Value> fieldRegs;
  Value selfPtr;
  Value clk;
  bool hasState = false;
  Value trueConstant;
  Value falseConstant;
  Location loc;
  hw::HWModuleOp builtModule;
};

LogicalResult CirctModuleEmitter::collectPorts() {
  llvm::StringSet<> seen;

  for (Operation *fn : methods) {
    auto func = dyn_cast<FunctionOpInterface>(fn);
    if (!func)
      continue;
    auto funcType = getFuncTypeGenerator(fn);
    if (!funcType)
      continue;
    auto body = funcType.getBody();

    ArrayAttr returnNames;
    if (auto dict = source->getAttrOfType<DictionaryAttr>(kHdlReturnNamesAttr)) {
      auto key = symbolSourcePrefix(
          fn->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName())
              .getValue());
      returnNames = dyn_cast_or_null<ArrayAttr>(dict.get(key));
    }

    // Inputs: argument 0 is `self` for every method.
    unsigned argIndex = 0;
    for (Type argType : body.getArguments()) {
      unsigned signatureIndex = argIndex++;
      if (signatureIndex == 0)
        continue;
      unsigned width = getBitWidth(argType);
      if (!width) {
        fn->emitError() << "HDL lowering: unsupported port type " << argType;
        return failure();
      }
      std::string name;
      if (auto dict = source->getAttrOfType<DictionaryAttr>(kHdlArgNamesAttr)) {
        auto methodKey = symbolSourcePrefix(
            fn->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName())
                .getValue());
        if (auto names = dyn_cast_or_null<ArrayAttr>(dict.get(methodKey)))
          if (signatureIndex < names.size())
            name = cast<StringAttr>(names[signatureIndex]).getValue().str();
      }
      if (name.empty() || name == "self")
        name = "arg" + std::to_string(signatureIndex);
      if (!seen.insert(name).second) {
        fn->emitError() << "HDL lowering: duplicate port name '" << name << "'";
        return failure();
      }
      ports.push_back({name, width, /*isInput=*/true});
    }

    // Outputs.
    unsigned outIndex = 0;
    for (Type resType : body.getResults()) {
      unsigned width = getBitWidth(resType);
      if (!width) {
        fn->emitError() << "HDL lowering: unsupported port type " << resType;
        return failure();
      }
      std::string name;
      if (returnNames && outIndex < returnNames.size())
        name = cast<StringAttr>(returnNames[outIndex]).getValue().str();
      if (name.empty())
        name = outIndex == 0 ? "out" : "out" + std::to_string(outIndex);
      if (!seen.insert(name).second) {
        fn->emitError() << "HDL lowering: duplicate port name '" << name << "'";
        return failure();
      }
      ports.push_back({name, width, /*isInput=*/false});
      ++outIndex;
    }
  }
  return success();
}

LogicalResult CirctModuleEmitter::findMethods() {
  std::string prefixStr = (structName + "::").str();
  StringRef prefix = prefixStr;
  for (Operation &op : source.getBody()->getOperations()) {
    auto symbol = op.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (!symbol || !symbol.getValue().starts_with(prefix))
      continue;
    // Compiler-synthesized members (__init__, __deinit__, ...) are not
    // processes.
    StringRef method = symbol.getValue().drop_front(prefix.size());
    if (method.starts_with("__"))
      continue;
    methods.push_back(&op);
  }
  if (methods.empty()) {
    source.emitError() << "HDL lowering: @module struct '" << structName
                       << "' has no elaborated methods";
    return failure();
  }
  for (Operation *method : methods) {
    method->walk([&](Operation *op) {
      if (op->getName().getStringRef() == "kgen.struct.gep")
        hasState = true;
    });
  }
  if (methods.size() != 1) {
    source.emitError() << "HDL lowering: multiple processes per module are "
                          "not supported yet ("
                       << structName << " has " << methods.size() << ")";
    return failure();
  }
  return success();
}

Value CirctModuleEmitter::getValue(Value value) {
  auto it = values.find(value);
  if (it != values.end())
    return it->second;
  return {};
}

Value CirctModuleEmitter::getConstant(bool value) {
  Value &slot = value ? trueConstant : falseConstant;
  if (slot)
    return slot;
  unsigned width = 1;
  slot = hw::ConstantOp::create(builder, loc, builder.getIntegerType(width),
                                value ? 1 : 0);
  return slot;
}

Value CirctModuleEmitter::getOrCreateReg(unsigned fieldIndex, Type type) {
  auto found = fieldRegs.find(fieldIndex);
  if (found != fieldRegs.end())
    return found->second;
  auto zero = hw::ConstantOp::create(builder, loc, type, 0);
  auto reg = seq::CompRegOp::create(builder, loc, zero, clk);
  fieldRegs[fieldIndex] = reg;
  return reg;
}

LogicalResult CirctModuleEmitter::emitOp(Operation *op, Value &returnValue) {
  StringRef name = op->getName().getStringRef();

  if (name == "hlcf.return") {
    if (op->getNumOperands() != 1)
      return op->emitError()
             << "HDL lowering: expected exactly one return value";
    returnValue = getValue(op->getOperand(0));
    if (!returnValue)
      return op->emitError() << "HDL lowering: return value was not lowered";
    return success();
  }

  if (name == "kgen.param.constant" || name == "pop.constant") {
    if (auto value = getConstantBool(op)) {
      values[op->getResult(0)] = getConstant(*value);
      return success();
    }
    if (auto value = getConstantInt(op)) {
      values[op->getResult(0)] =
          hw::ConstantOp::create(builder, loc, *value);
      return success();
    }
    return op->emitError()
           << "HDL lowering: unsupported constant in HDL method";
  }

  if (name == "kgen.call") {
    StringRef callee = callCalleeName(op);
    Value operand = op->getNumOperands() == 1 ? getValue(op->getOperand(0))
                                              : Value();
    if (callee.contains("::__bool__")) {
      if (!operand)
        return op->emitError() << "HDL lowering: __bool__ operand not lowered";
      values[op->getResult(0)] = operand;
      return success();
    }
    if (callee.contains("::__invert__")) {
      if (!operand)
        return op->emitError()
               << "HDL lowering: __invert__ operand not lowered";
      values[op->getResult(0)] =
          comb::XorOp::create(builder, loc, operand, getConstant(true));
      return success();
    }

    // SIMD lane arithmetic from the primitive `UInt8`/`UInt16` DSL path.
    if (op->getNumOperands() == 2) {
      Value lhs = getValue(op->getOperand(0));
      Value rhs = getValue(op->getOperand(1));
      if (!lhs || !rhs)
        return op->emitError() << "HDL lowering: binary operand was not lowered";
      if (callee.contains("SIMD::__add__")) {
        values[op->getResult(0)] = comb::AddOp::create(builder, loc, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__sub__")) {
        values[op->getResult(0)] = comb::SubOp::create(builder, loc, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__mul__")) {
        values[op->getResult(0)] = comb::MulOp::create(builder, loc, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__and__")) {
        values[op->getResult(0)] = comb::AndOp::create(builder, loc, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__or__")) {
        values[op->getResult(0)] = comb::OrOp::create(builder, loc, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__xor__")) {
        values[op->getResult(0)] = comb::XorOp::create(builder, loc, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__eq__")) {
        values[op->getResult(0)] = comb::ICmpOp::create(
            builder, loc, comb::ICmpPredicate::eq, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__ne__")) {
        values[op->getResult(0)] = comb::ICmpOp::create(
            builder, loc, comb::ICmpPredicate::ne, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__lt__")) {
        values[op->getResult(0)] = comb::ICmpOp::create(
            builder, loc, comb::ICmpPredicate::ult, lhs, rhs);
        return success();
      }
      if (callee.contains("SIMD::__le__")) {
        values[op->getResult(0)] = comb::ICmpOp::create(
            builder, loc, comb::ICmpPredicate::ule, lhs, rhs);
        return success();
      }
    }

    return op->emitError() << "HDL lowering: unsupported call to '" << callee
                           << "'";
  }

  if (name == "pop.simd.xor" || name == "pop.xor") {
    Value lhs = getValue(op->getOperand(0));
    Value rhs = getValue(op->getOperand(1));
    if (!lhs || !rhs)
      return op->emitError() << "HDL lowering: xor operand was not lowered";
    values[op->getResult(0)] = comb::XorOp::create(builder, loc, lhs, rhs);
    return success();
  }

  if (name == "kgen.struct.gep") {
    auto index = op->getAttrOfType<IntegerAttr>("index");
    if (!index || op->getNumOperands() != 1 || op->getOperand(0) != selfPtr)
      return op->emitError()
             << "HDL lowering: unsupported struct field access";
    fieldPtrs[op->getResult(0)] = index.getInt();
    return success();
  }

  if (name == "pop.store") {
    Value stored = getValue(op->getOperand(0));
    if (!stored)
      return op->emitError() << "HDL lowering: stored value was not lowered";
    auto field = fieldPtrs.find(op->getOperand(1));
    if (field != fieldPtrs.end()) {
      auto reg = getOrCreateReg(field->second, stored.getType());
      reg.getDefiningOp()->setOperand(0, stored);
      return success();
    }
    values[op->getOperand(1)] = stored;
    return success();
  }

  if (name == "pop.load") {
    auto field = fieldPtrs.find(op->getOperand(0));
    if (field != fieldPtrs.end()) {
      auto type = getHwType(op->getResult(0).getType());
      if (!type)
        return op->emitError() << "HDL lowering: unsupported state type";
      values[op->getResult(0)] = getOrCreateReg(field->second, type);
      return success();
    }
    Value stored = getValue(op->getOperand(0));
    if (!stored)
      return op->emitError() << "HDL lowering: loaded value was not lowered";
    values[op->getResult(0)] = stored;
    return success();
  }

  // Ignore lifetime/bookkeeping ops.
  if (name == "pop.stack_allocation" ||
      name == "pop.stack_alloc.lifetime.start" ||
      name == "pop.stack_alloc.lifetime.end" || name.starts_with("debuginfo."))
    return success();

  return op->emitError() << "HDL lowering: unsupported operation '" << name
                         << "' in an HDL method";
}

LogicalResult CirctModuleEmitter::emitOps(Operation *fn, Value &returnValue) {
  auto func = dyn_cast<FunctionOpInterface>(fn);
  if (!func || func.getFunctionBody().empty())
    return fn->emitError() << "HDL lowering: method has no body";
  Block &entry = func.getFunctionBody().front();
  for (Operation &op : entry.getOperations())
    if (failed(emitOp(&op, returnValue)))
      return failure();
  return success();
}

LogicalResult CirctModuleEmitter::build() {
  if (failed(findMethods()) || failed(collectPorts()))
    return failure();

  loc = source.getLoc();
  MLIRContext *ctx = source.getContext();

  SmallVector<hw::PortInfo> inputs;
  SmallVector<hw::PortInfo> outputs;
  for (const Port &port : ports) {
    hw::PortInfo info;
    info.name = StringAttr::get(ctx, port.name);
    info.type = IntegerType::get(ctx, port.width);
    if (port.isInput) {
      info.dir = hw::ModulePort::Direction::Input;
      info.argNum = inputs.size();
      inputs.push_back(info);
    } else {
      info.dir = hw::ModulePort::Direction::Output;
      info.argNum = outputs.size();
      outputs.push_back(info);
    }
  }

  if (hasState) {
    hw::PortInfo info;
    info.name = StringAttr::get(ctx, "clk");
    info.type = seq::ClockType::get(ctx);
    info.dir = hw::ModulePort::Direction::Input;
    info.argNum = inputs.size();
    inputs.push_back(info);
  }

  // Use the struct's unqualified name as the module name.
  StringRef displayName = StringRef(structName).rsplit("::").second;

  builder.setInsertionPointToEnd(scratch.getBody());
  builtModule = hw::HWModuleOp::create(
      builder, loc, StringAttr::get(ctx, displayName),
      hw::ModulePortInfo(inputs, outputs));

  Block *body = builtModule.getBodyBlock();
  size_t portIndex = 0;
  size_t argIndex = 0;
  for (Operation *fn : methods) {
    auto func = cast<FunctionOpInterface>(fn);
    Block &entry = func.getFunctionBody().front();
    for (BlockArgument arg : entry.getArguments()) {
      if (argIndex++ == 0) {
        selfPtr = arg;
        continue;
      }
      values[arg] = body->getArgument(portIndex++);
    }
    if (hasState)
      clk = body->getArgument(portIndex);

    Value returnValue;
    // The module builder created an `hw.output` terminator; emit before it.
    builder.setInsertionPoint(body->getTerminator());
    if (failed(emitOps(fn, returnValue)))
      return failure();

    // `hw.module` was built with a terminator; fill in the outputs.
    auto output = cast<hw::OutputOp>(body->getTerminator());
    output->setOperands(ValueRange{returnValue});
  }

  return success();
}

class HDLToCIRCTPass
    : public PassWrapper<HDLToCIRCTPass, OperationPass<ModuleOp>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(HDLToCIRCTPass)

  explicit HDLToCIRCTPass(const HDLEmitOptions &options) : options(options) {}
  HDLToCIRCTPass(const HDLToCIRCTPass &other)
      : PassWrapper(other), options(other.options) {}

  StringRef getArgument() const override { return "hdl-to-circt"; }
  StringRef getDescription() const override {
    return "Lower HDL @module structs to CIRCT hw/comb ops";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    raw_ostream &os = options.output ? *options.output : llvm::outs();

    if (options.dumpSourceIR) {
      module.print(os);
      os << "\n";
      return;
    }

    // Make sure the dialects are loaded (not just registered): MLIR prints an
    // unloaded dialect's ops in generic form.
    module.getContext()->getOrLoadDialect<hw::HWDialect>();
    module.getContext()->getOrLoadDialect<comb::CombDialect>();

    auto modules = module->getAttrOfType<ArrayAttr>(kHdlModulesAttr);
    if (!modules || modules.empty()) {
      module.emitError()
          << "HDL lowering: no `@module` struct found (the design must mark "
             "module structs with @module)";
      signalPassFailure();
      return;
    }

    // Build into a scratch module so `--emit=circt` can print each module with
    // CIRCT's custom assembly (an op attached to the KGEN module prints in
    // generic form here). In SV mode the driver takes ownership and runs
    // seq-to-sv plus ExportVerilog after this pass manager has finished.
    OwningOpRef<ModuleOp> scratch = ModuleOp::create(module.getLoc());
    for (Attribute attr : modules) {
      auto name = cast<StringAttr>(attr).getValue();
      CirctModuleEmitter emitter(module, name, *scratch);
      if (failed(emitter.build())) {
        signalPassFailure();
        return;
      }
      if (!options.emitSV) {
        emitter.getModule().print(os);
        os << "\n";
      }
    }

    if (options.emitSV) {
      if (!options.builtModule) {
        module.emitError()
            << "HDL lowering: no destination for the built CIRCT module";
        signalPassFailure();
        return;
      }
      *options.builtModule = std::move(scratch);
    }
  }

  HDLEmitOptions options;
};

} // namespace

std::unique_ptr<Pass> createHDLCaptureNamesPass() {
  return std::make_unique<HDLCaptureNamesPass>();
}

std::unique_ptr<Pass> createHDLToCIRCTPass(const HDLEmitOptions &options) {
  return std::make_unique<HDLToCIRCTPass>(options);
}

std::unique_ptr<Pass> createHDLSeqToSVPass() {
  return circt::createLowerSeqToSVPass();
}

LogicalResult exportHDLSystemVerilog(ModuleOp module, raw_ostream &os) {
  return circt::exportVerilog(module, os);
}


} // namespace M::KGEN
