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

#include <functional>
#include <map>
#include <memory>
#include <set>
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

using ParamBindings = llvm::StringMap<llvm::APInt>;

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
    // `index`/`uindex` are pointer-sized integers; use the host width.
    if (dtype->isIndex() || dtype->isUIndex())
      return static_cast<unsigned>(64 * *size);
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

/// Decode an integer from a typed parameter attribute, resolving parameter
/// declarations through `bindings` when this is a specialization.
static std::optional<llvm::APInt>
getTypedAttrInt(TypedAttr attr, const ParamBindings *bindings = nullptr) {
  if (!attr)
    return std::nullopt;
  if (auto intAttr = dyn_cast<IntegerAttr>(attr))
    return intAttr.getValue();
  if (auto simd = dyn_cast<KGEN::SIMDAttr>(attr)) {
    if (simd.getValues().size() == 1)
      return simd.getValues()[0].getIntVal();
  }
  if (auto declRef = dyn_cast<KGEN::ParamDeclRefAttr>(attr)) {
    if (bindings) {
      auto found = bindings->find(declRef.getName().getValue());
      if (found != bindings->end())
        return found->second;
    }
  }
  if (auto indexRef = dyn_cast<KGEN::ParamIndexRefAttr>(attr)) {
    if (bindings && indexRef.getDepth() == 0) {
      auto found =
          bindings->find("#" + std::to_string(indexRef.getIndex()));
      if (found != bindings->end())
        return found->second;
    }
  }
  if (auto expr = dyn_cast<KGEN::ParamOperatorAttr>(attr)) {
    if (!bindings)
      return std::nullopt;
    auto opcode = expr.getOpcode();
    if (opcode != KGEN::POC::Add && opcode != KGEN::POC::Mul &&
        opcode != KGEN::POC::MulNoWrap)
      return std::nullopt;
    llvm::APInt accum(64, opcode == KGEN::POC::Add ? 0 : 1);
    for (TypedAttr operand : expr.getOperands()) {
      auto value = getTypedAttrInt(operand, bindings);
      if (!value)
        return std::nullopt;
      auto bits = value->zextOrTrunc(64);
      accum = opcode == KGEN::POC::Add ? accum + bits : accum * bits;
    }
    return accum;
  }
  return std::nullopt;
}

/// Return the source-level signature recorded on a method, if it is available.
/// The lowered signature has already erased named DSL types into flat memory
/// layouts; this one still says `Bits[8]`.
static KGEN::FuncType getSourceFuncType(Operation *op) {
  auto typeParam = dyn_cast_or_null<KGEN::TypeParamAttr>(
      op->getAttr("sourceFuncTypeGenerator"));
  if (!typeParam)
    return {};
  auto generator =
      dyn_cast<KGEN::FuncTypeGeneratorType>(typeParam.getTypeValue());
  if (!generator)
    return {};
  return generator.getBody();
}

/// Resolve a field/parameter type attribute to the type that carries the DSL
/// type value (`Bits[W]`, a `SIMD` scalar, ...).
static Type getTypeFromAttr(TypedAttr attr) {
  if (!attr)
    return {};
  if (auto typeParam = dyn_cast<KGEN::TypeParamAttr>(attr))
    return typeParam.getTypeValue();
  return attr.getType();
}

/// Return the first callee type parameter as a bit width, if present. Filled
/// by a `Bits[W]` method, this is `W`.
static unsigned getCallParamWidth(Operation *op,
                                  const ParamBindings *bindings = nullptr) {
  auto symbol = KGEN::FuncSymbolGenerator::dynCast(op->getAttr("callee"));
  if (!symbol)
    return 0;
  auto params = symbol.getParamValues();
  if (params.empty())
    return 0;
  if (auto width = getTypedAttrInt(params.front(), bindings))
    return static_cast<unsigned>(width->getZExtValue());
  return 0;
}

/// Return the leaf name of a DSL type reference (`Bits`, `Logic`, ...), or
/// empty if this is not a `typevalue<genref<...>>`.
static StringRef getDslTypeName(Type type) {
  if (auto ptr = dyn_cast<KGEN::PointerType>(type))
    type = ptr.getElementType();
  auto typeValue = dyn_cast<KGEN::TypeValueType>(type);
  if (!typeValue)
    return {};
  auto ref = dyn_cast<KGEN::TypeGeneratorRefAttr>(typeValue.getTypeValue());
  if (!ref)
    return {};
  return ref.getSymbol().getLeafReference().getValue();
}

static bool isLogicType(Type type) {
  return getDslTypeName(type).contains("Logic");
}

/// Return the HDL bit width of a DSL port type. `Bits[W]`/`Logic[W]` source
/// types carry `W` as a type parameter; anything else is resolved from its
/// lowered representation.
static unsigned getHdlWidth(Type type,
                            const ParamBindings *bindings = nullptr) {
  if (auto ptr = dyn_cast<KGEN::PointerType>(type))
    type = ptr.getElementType();
  if (auto typeValue = dyn_cast<KGEN::TypeValueType>(type)) {
    auto ref = dyn_cast<KGEN::TypeGeneratorRefAttr>(typeValue.getTypeValue());
    auto name = ref ? ref.getSymbol().getLeafReference().getValue() : StringRef();
    if (ref && (name.contains("Bits") || name.contains("Logic"))) {
      auto params = ref.getParamValues();
      if (!params.empty())
        if (auto width = getTypedAttrInt(params.front(), bindings))
          return static_cast<unsigned>(width->getZExtValue());
    }
    return 0;
  }
  return getBitWidth(type);
}

/// Return the first type parameter of a DSL reference (for example the `W` of
/// `Bits[W]` or `Counter[W]`), resolving declarations through `bindings`.
static std::optional<llvm::APInt>
getDslTypeBinding(Type type, const ParamBindings *bindings = nullptr) {
  if (auto ptr = dyn_cast<KGEN::PointerType>(type))
    type = ptr.getElementType();
  auto typeValue = dyn_cast<KGEN::TypeValueType>(type);
  if (!typeValue)
    return std::nullopt;
  auto ref = dyn_cast<KGEN::TypeGeneratorRefAttr>(typeValue.getTypeValue());
  if (!ref || ref.getParamValues().empty())
    return std::nullopt;
  return getTypedAttrInt(ref.getParamValues().front(), bindings);
}

/// Return every type parameter of a DSL reference.
static SmallVector<llvm::APInt>
getDslTypeBindings(Type type, const ParamBindings *bindings = nullptr) {
  SmallVector<llvm::APInt> result;
  if (auto ptr = dyn_cast<KGEN::PointerType>(type))
    type = ptr.getElementType();
  auto typeValue = dyn_cast<KGEN::TypeValueType>(type);
  if (!typeValue)
    return result;
  auto ref = dyn_cast<KGEN::TypeGeneratorRefAttr>(typeValue.getTypeValue());
  if (!ref)
    return result;
  for (TypedAttr param : ref.getParamValues())
    if (auto value = getTypedAttrInt(param, bindings))
      result.push_back(*value);
  return result;
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

/// Return the source method name from a `Struct::method(...)` symbol.
static std::string getMethodName(StringRef symbol, StringRef structName) {
  StringRef rest = symbol.drop_front(structName.size() + 2);
  return rest.take_front(rest.find('(')).str();
}

/// Decode a scalar integer constant op, if this is one.
static std::optional<llvm::APInt>
getConstantInt(Operation *op, const ParamBindings *bindings = nullptr) {
  if (auto value = op->getAttr("value"))
    if (auto typed = dyn_cast<TypedAttr>(value))
      if (auto result = getTypedAttrInt(typed, bindings))
        return result;
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
  CirctModuleEmitter(ModuleOp source, StringRef structName, StringRef moduleName,
                     const ParamBindings &bindings, ModuleOp scratch,
                     ArrayAttr hdlModules)
      : source(source), structName(structName), moduleName(moduleName),
        bindings(bindings), scratch(scratch), hdlModules(hdlModules),
        builder(scratch.getContext()), loc(scratch.getLoc()) {}

  LogicalResult build();
  hw::HWModuleOp getModule() const { return builtModule; }

private:
  struct Port {
    std::string name;
    unsigned width;
    bool isInput;
    bool isLogic;
  };

  struct LogicValue {
    Value val;
    Value xz;
    explicit operator bool() const { return val && xz; }
  };

  LogicalResult collectPorts();
  LogicalResult collectFieldWidths();
  LogicalResult collectResetValues();
  LogicalResult collectMethodDomains();
  LogicalResult findMethods();
  LogicalResult emitOps(Operation *fn, Value &returnValue);
  LogicalResult emitBlock(Block &block, Value condition, Value &returnValue);
  LogicalResult emitOp(Operation *op, Value condition, Value &returnValue);
  LogicalResult storeField(unsigned fieldIndex, Value value, Value condition);
  void convertCEToPlain(unsigned fieldIndex);
  Operation *findBuiltModule(StringRef name);
  Value getValue(Value value);
  LogicValue getLogicValue(Value value);
  LogicValue getOrCreateLogicReg(unsigned fieldIndex, unsigned width);
  LogicalResult storeLogicField(unsigned fieldIndex, LogicValue value,
                                Value condition);
  Value bitNot(Value value);
  Value getConstant(bool value);
  Value getOrCreateReg(unsigned fieldIndex, Type type);
  SmallVector<Value> &getOrCreateMemory(unsigned fieldIndex);
  Value createRegister(unsigned id, Type type, llvm::APInt resetValue,
                        llvm::APInt initialValue, int style);

  ModuleOp source;
  StringRef structName;
  std::string moduleName;
  ParamBindings bindings;
  ModuleOp scratch;
  ArrayAttr hdlModules;
  OpBuilder builder;

  SmallVector<Port> ports;
  SmallVector<Operation *> methods;

  DenseMap<Value, Value> values;
  DenseMap<Value, LogicValue> logicValues;
  DenseMap<unsigned, LogicValue> logicRegs;
  DenseMap<unsigned, LogicValue> logicNext;
  DenseMap<Value, llvm::APInt> intConstants;
  DenseMap<Value, unsigned> fieldPtrs;
  DenseMap<Value, unsigned> instancePtrs;
  DenseMap<unsigned, Value> fieldRegs;
  DenseMap<unsigned, Value> fieldNext;
  DenseMap<unsigned, Value> fieldEnable;
  DenseMap<unsigned, bool> fieldMuxed;
  DenseMap<unsigned, unsigned> fieldWriter;
  DenseMap<unsigned, std::set<unsigned>> fieldReaders;
  unsigned currentMethod = 0;
  DenseMap<unsigned, llvm::APInt> resetValues;
  SmallVector<unsigned> fieldWidths;
  SmallVector<unsigned> methodOutputCounts;
  SmallVector<bool> methodHasState;
  SmallVector<std::string> methodNames;
  SmallVector<std::string> fieldNames;
  SmallVector<std::string> fieldStructNames;
  SmallVector<std::string> fieldModuleNames;
  SmallVector<bool> fieldIsInstance;
  SmallVector<bool> fieldIsLogic;
  SmallVector<bool> fieldIsConfig;
  SmallVector<bool> fieldIsMemory;
  SmallVector<unsigned> fieldMemWidths;
  SmallVector<unsigned> fieldMemDepths;
  SmallVector<int> fieldResetStyle;
  DenseMap<unsigned, SmallVector<Value>> memoryRegs;
  int resetStyle = 0;
  std::optional<llvm::APInt> powerOnValue;
  Value selfPtr;
  Value resultPtr;
  Value returnXz;
  bool returnIsLogic = false;
  Value clk;
  Value resetSignal;
  Value trueConstant;
  Value falseConstant;
  Location loc;
  hw::HWModuleOp builtModule;
};

LogicalResult CirctModuleEmitter::collectPorts() {
  llvm::StringSet<> seen;

  for (unsigned methodIndex = 0; methodIndex < methods.size();
       ++methodIndex) {
    Operation *fn = methods[methodIndex];
    auto funcType = getFuncTypeGenerator(fn);
    if (!funcType)
      continue;
    auto body = funcType.getBody();
    auto sourceFunc = getSourceFuncType(fn);

    auto methodKey = symbolSourcePrefix(
        fn->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName())
            .getValue());
    ArrayAttr argNames;
    if (auto dict = source->getAttrOfType<DictionaryAttr>(kHdlArgNamesAttr))
      argNames = dyn_cast_or_null<ArrayAttr>(dict.get(methodKey));
    ArrayAttr returnNames;
    if (auto dict = source->getAttrOfType<DictionaryAttr>(kHdlReturnNamesAttr))
      returnNames = dyn_cast_or_null<ArrayAttr>(dict.get(methodKey));

    unsigned outputIndex = 0;
    unsigned methodOutputCount = 0;

    // Inputs and by-ref outputs, walking the source signature so that named
    // DSL types keep their declared width.
    unsigned argIndex = 0;
    for (Type argType : body.getArguments()) {
      unsigned index = argIndex++;
      if (index == 0)
        continue; // `self`
      bool isResult = sourceFunc &&
                      sourceFunc.getArgConvention(index) ==
                          ArgConvention::ByRefResult;
      Type sourceType = sourceFunc ? sourceFunc.getArgument(index) : argType;
      unsigned width = getHdlWidth(sourceType, &bindings);
      if (!width)
        width = getHdlWidth(argType, &bindings);
      if (!width) {
        fn->emitError() << "HDL lowering: unsupported port type " << sourceType;
        return failure();
      }

      std::string name;
      if (isResult) {
        if (returnNames && outputIndex < returnNames.size())
          name = cast<StringAttr>(returnNames[outputIndex]).getValue().str();
        if (name.empty()) {
          if (methods.size() == 1)
            name = outputIndex == 0 ? "out"
                                    : "out" + std::to_string(outputIndex);
          else
            name = methodNames[methodIndex] + "_out" +
                   (outputIndex == 0 ? "" : std::to_string(outputIndex));
        }
        ++outputIndex;
        ++methodOutputCount;
      } else {
        if (argNames && index < argNames.size())
          name = cast<StringAttr>(argNames[index]).getValue().str();
        if (name.empty() || name == "self")
          name = "arg" + std::to_string(index);
      }
      if (!seen.insert(name).second) {
        fn->emitError() << "HDL lowering: duplicate port name '" << name << "'";
        return failure();
      }
      bool isLogic = isLogicType(sourceType);
      ports.push_back({name, width, /*isInput=*/!isResult, isLogic});
      if (isLogic) {
        // A 4-state value is carried as a value net plus an X/Z mask net.
        std::string maskName = name + "_xz";
        if (!seen.insert(maskName).second) {
          fn->emitError() << "HDL lowering: duplicate port name '" << maskName
                          << "'";
          return failure();
        }
        ports.push_back({maskName, width, /*isInput=*/!isResult, false});
      }
    }

    // By-value results (the primitive DSL path returns scalars directly).
    for (Type resType : body.getResults()) {
      if (isa<KGEN::NoneType>(resType))
        continue;
      unsigned width = getHdlWidth(resType, &bindings);
      if (!width) {
        fn->emitError() << "HDL lowering: unsupported port type " << resType;
        return failure();
      }
      std::string name;
      if (returnNames && outputIndex < returnNames.size())
        name = cast<StringAttr>(returnNames[outputIndex]).getValue().str();
      if (name.empty()) {
        if (methods.size() == 1)
          name = outputIndex == 0 ? "out" : "out" + std::to_string(outputIndex);
        else
          name = methodNames[methodIndex] + "_out" +
                 (outputIndex == 0 ? "" : std::to_string(outputIndex));
      }
      ++outputIndex;
      ++methodOutputCount;
      if (!seen.insert(name).second) {
        fn->emitError() << "HDL lowering: duplicate port name '" << name << "'";
        return failure();
      }
      bool isLogic = isLogicType(resType);
      ports.push_back({name, width, /*isInput=*/false, isLogic});
      if (isLogic) {
        std::string maskName = name + "_xz";
        if (!seen.insert(maskName).second) {
          fn->emitError() << "HDL lowering: duplicate port name '" << maskName
                          << "'";
          return failure();
        }
        ports.push_back({maskName, width, /*isInput=*/false, false});
      }
    }
    methodOutputCounts.push_back(methodOutputCount);
  }
  return success();
}

LogicalResult CirctModuleEmitter::collectMethodDomains() {
  methodHasState.assign(methods.size(), false);
  for (unsigned m = 0; m < methods.size(); ++m) {
    auto func = dyn_cast<FunctionOpInterface>(methods[m]);
    if (!func || func.getFunctionBody().empty())
      continue;
    Value self = func.getFunctionBody().front().getArgument(0);
    bool stateful = false;
    methods[m]->walk([&](Operation *op) {
      if (op->getName().getStringRef() != "kgen.struct.gep" ||
          op->getNumOperands() != 1 || op->getOperand(0) != self)
        return;
      auto index = op->getAttrOfType<IntegerAttr>("index");
      if (!index)
        return;
      unsigned field = index.getInt();
      if (field >= fieldIsInstance.size())
        return;
      if (field < fieldIsConfig.size() && fieldIsConfig[field])
        return;
      if (!fieldIsInstance[field]) {
        stateful = true;
        return;
      }
      Operation *childOp = findBuiltModule(fieldModuleNames[field]);
      if (!childOp)
        return;
      for (hw::PortInfo port : cast<hw::HWModuleOp>(childOp).getPortList())
        if (port.dir == hw::ModulePort::Direction::Input &&
            isa<seq::ClockType>(port.type))
          stateful = true;
    });
    methodHasState[m] = stateful;
  }
  return success();
}

LogicalResult CirctModuleEmitter::collectResetValues() {
  std::string initPrefix = (structName + "::__init__(").str();
  std::string defaultName = (structName + "::__init__()").str();
  SmallVector<Operation *> constructors;
  for (Operation &op : source.getBody()->getOperations()) {
    auto symbol = op.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (!symbol)
      continue;
    // Prefer the default constructor; it is the one an instance starts from.
    if (symbol.getValue() == defaultName) {
      constructors.clear();
      constructors.push_back(&op);
      break;
    }
    if (symbol.getValue().starts_with(initPrefix) &&
        !symbol.getValue().contains("::__init__(move:"))
      constructors.push_back(&op);
  }

  for (Operation *constructor : constructors) {
    auto func = dyn_cast<FunctionOpInterface>(constructor);
    if (!func || func.getFunctionBody().empty())
      continue;
    Block &entry = func.getFunctionBody().front();
    if (entry.getNumArguments() == 0)
      continue;
    Value self = entry.getArgument(0);

    DenseMap<Value, unsigned> fieldIndexes;
    DenseMap<Value, llvm::APInt> constants;
    for (Operation &op : entry.getOperations()) {
      StringRef name = op.getName().getStringRef();
      if (name == "kgen.struct.gep") {
        auto index = op.getAttrOfType<IntegerAttr>("index");
        if (index && op.getNumOperands() == 1 && op.getOperand(0) == self)
          fieldIndexes[op.getResult(0)] = index.getInt();
        continue;
      }
      if (name == "kgen.param.constant" || name == "pop.constant") {
        if (auto value = getConstantInt(&op, &bindings))
          constants[op.getResult(0)] = *value;
        continue;
      }
      if (name == "pop.store") {
        auto field = fieldIndexes.find(op.getOperand(1));
        if (field == fieldIndexes.end())
          continue;
        Operation *valueOp = op.getOperand(0).getDefiningOp();
        if (auto value = valueOp ? getConstantInt(valueOp, &bindings)
                                     : std::nullopt)
          resetValues[field->second] = *value;
        continue;
      }
      if (name != "kgen.call")
        continue;

      StringRef callee = callCalleeName(&op);
      if (!callee.contains("Bits::__init__") &&
          !callee.contains("Logic::__init__") &&
          !callee.contains("Resettable::__init__") &&
          !callee.contains("Mem::__init__"))
        continue;
      // A direct `Bits[W](constant)` assignment can initialize the field
      // through the field pointer without a temporary.
      if (op.getNumOperands() == 2 && !callee.contains("__init__(move:")) {
        auto field = fieldIndexes.find(op.getOperand(1));
        if (field == fieldIndexes.end())
          continue;
        Operation *valueOp = op.getOperand(0).getDefiningOp();
        auto value = constants.find(op.getOperand(0));
        std::optional<llvm::APInt> result;
        if (value != constants.end())
          result = value->second;
        else if (valueOp)
          result = getConstantInt(valueOp, &bindings);
        if (result)
          resetValues[field->second] = *result;
        continue;
      }
      // Zero-argument `Bits[W]()` leaves the field zero-initialized.
      if (op.getNumOperands() == 1) {
        auto field = fieldIndexes.find(op.getOperand(0));
        if (field != fieldIndexes.end())
          resetValues[field->second] = llvm::APInt(1, 0);
      }
    }
  }
  return success();
}

LogicalResult CirctModuleEmitter::collectFieldWidths() {
  Operation *structOp = nullptr;
  for (Operation &op : source.getBody()->getOperations()) {
    auto symbol = op.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (!symbol || symbol.getValue() != structName)
      continue;
    if (isa<KGEN::StructGeneratorOp>(op) || isa<KGEN::StructInstanceOp>(op)) {
      structOp = &op;
      break;
    }
  }
  if (!structOp)
    return success();

  Type domainType;
  if (auto generator = dyn_cast<KGEN::StructGeneratorOp>(structOp))
    domainType = generator.getValueDomainType();
  else
    domainType = cast<KGEN::StructInstanceOp>(structOp).getValueDomainType();
  auto structType = dyn_cast<StructInstanceType>(domainType);
  if (!structType)
    return success();

  for (StructDefFieldAttr field : structType.getFields()) {
    Type fieldType = getTypeFromAttr(field.getTypeValue());
    fieldNames.push_back(field.getName().getValue().str());
    std::string typeName = getDslTypeName(fieldType).str();
    fieldStructNames.push_back(typeName);

    bool isPowerOn = StringRef(typeName).contains("PowerOn");
    bool isConfig =
        StringRef(typeName).contains("ResetStyle") || isPowerOn;
    bool isMemory = !isConfig && StringRef(typeName).ends_with("Mem");
    fieldIsConfig.push_back(isConfig);
    fieldIsMemory.push_back(isMemory);
    fieldMemWidths.push_back(0);
    fieldMemDepths.push_back(0);
    fieldResetStyle.push_back(resetStyle);
    if (isConfig) {
      if (auto value = getDslTypeBinding(fieldType, &bindings)) {
        if (isPowerOn)
          powerOnValue = *value;
        else
          resetStyle = static_cast<int>(value->getZExtValue());
      }
      fieldWidths.push_back(0);
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(false);
      fieldModuleNames.push_back({});
      continue;
    }

    if (!isMemory && StringRef(typeName).contains("Resettable")) {
      auto params = getDslTypeBindings(fieldType, &bindings);
      if (params.size() >= 2) {
        fieldWidths.push_back(params[0].getZExtValue());
        fieldResetStyle.back() = params[1].getZExtValue();
      } else {
        fieldWidths.push_back(0);
      }
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(false);
      fieldModuleNames.push_back({});
      continue;
    }

    if (isMemory) {
      auto params = getDslTypeBindings(fieldType, &bindings);
      if (params.size() >= 2) {
        fieldMemWidths.back() = params[0].getZExtValue();
        fieldMemDepths.back() = params[1].getZExtValue();
      }
      fieldWidths.push_back(0);
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(false);
      fieldModuleNames.push_back({});
      continue;
    }

    fieldWidths.push_back(getHdlWidth(fieldType, &bindings));
    bool isInstance = false;
    if (!typeName.empty())
      for (Attribute module : hdlModules)
        if (cast<StringAttr>(module).getValue() == typeName) {
          isInstance = true;
          break;
        }
    fieldIsInstance.push_back(isInstance);
    fieldIsLogic.push_back(getDslTypeName(fieldType).contains("Logic"));
    if (isInstance) {
      std::string display = StringRef(typeName).rsplit("::").second.str();
      for (auto binding : getDslTypeBindings(fieldType, &bindings))
        display += "_" + std::to_string(binding.getZExtValue());
      fieldModuleNames.push_back(display);
    } else {
      fieldModuleNames.push_back({});
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
    methodNames.push_back(getMethodName(symbol.getValue(), structName));
  }
  if (methods.empty()) {
    source.emitError() << "HDL lowering: @module struct '" << structName
                       << "' has no elaborated methods";
    return failure();
  }
  return success();
}

SmallVector<Value> &
CirctModuleEmitter::getOrCreateMemory(unsigned fieldIndex) {
  auto found = memoryRegs.find(fieldIndex);
  if (found != memoryRegs.end())
    return found->second;
  auto &regs = memoryRegs[fieldIndex];
  unsigned width = fieldMemWidths[fieldIndex];
  unsigned depth = fieldMemDepths[fieldIndex];
  auto type = IntegerType::get(builder.getContext(), width);
  auto zero = hw::ConstantOp::create(builder, loc, type, 0);
  llvm::APInt resetBits(width, 0);
  if (auto value = resetValues.find(fieldIndex); value != resetValues.end())
    resetBits = value->second.zextOrTrunc(width);
  llvm::APInt initialBits = resetBits;
  if (powerOnValue)
    initialBits = powerOnValue->zextOrTrunc(width);
  auto resetValue = hw::ConstantOp::create(builder, loc, resetBits);
  auto ceZero =
      hw::ConstantOp::create(builder, loc, builder.getIntegerType(1), 0);
  Value reset = (resetStyle & 1) ? bitNot(resetSignal) : resetSignal;
  bool async = resetStyle >= 2;
  Value initial;
  if (!async)
    initial = seq::createConstantInitialValue(
        builder, loc, IntegerAttr::get(type, initialBits));
  for (unsigned k = 0; k < depth; ++k) {
    auto name = StringAttr::get(
        builder.getContext(),
        "mem_" + std::to_string(fieldIndex) + "_" + std::to_string(k));
    if (async) {
      regs.push_back(seq::FirRegOp::create(
          builder, loc, zero, clk, name, reset, resetValue,
          hw::InnerSymAttr(), /*isAsync=*/true,
          /*preset=*/IntegerAttr::get(type, initialBits)));
    } else {
      regs.push_back(seq::CompRegClockEnabledOp::create(
          builder, loc, zero, clk, ceZero, reset, resetValue, name, initial));
    }
  }
  return regs;
}

Operation *CirctModuleEmitter::findBuiltModule(StringRef name) {
  StringRef displayName = name.contains("::") ? name.rsplit("::").second : name;
  for (Operation &op : scratch.getBody()->getOperations())
    if (auto module = dyn_cast<hw::HWModuleOp>(&op))
      if (module.getModuleName() == displayName)
        return module;
  return nullptr;
}

Value CirctModuleEmitter::getValue(Value value) {
  auto it = values.find(value);
  if (it != values.end())
    return it->second;
  // Integer constants are materialized on first use so that values consumed
  // directly by a lowering pattern (for example a `Bits[W]` constructor
  // argument) do not leave dead operations behind.
  auto constant = intConstants.find(value);
  if (constant != intConstants.end()) {
    Value result =
        hw::ConstantOp::create(builder, loc, constant->second);
    values[value] = result;
    intConstants.erase(constant);
    return result;
  }
  auto field = fieldPtrs.find(value);
  if (field != fieldPtrs.end()) {
    unsigned index = field->second;
    if (index >= fieldWidths.size() || !fieldWidths[index])
      return {};
    if (index < fieldIsLogic.size() && fieldIsLogic[index])
      return {};
    if (index < fieldIsMemory.size() && fieldIsMemory[index])
      return {};
    fieldReaders[index].insert(currentMethod);
    auto type = IntegerType::get(value.getContext(), fieldWidths[index]);
    return getOrCreateReg(index, type);
  }
  return {};
}

CirctModuleEmitter::LogicValue CirctModuleEmitter::getLogicValue(Value value) {
  auto it = logicValues.find(value);
  if (it != logicValues.end())
    return it->second;
  auto field = fieldPtrs.find(value);
  if (field != fieldPtrs.end() && field->second < fieldIsLogic.size() &&
      fieldIsLogic[field->second]) {
    fieldReaders[field->second].insert(currentMethod);
    return getOrCreateLogicReg(field->second, fieldWidths[field->second]);
  }
  return {};
}

CirctModuleEmitter::LogicValue
CirctModuleEmitter::getOrCreateLogicReg(unsigned fieldIndex, unsigned width) {
  auto found = logicRegs.find(fieldIndex);
  if (found != logicRegs.end())
    return found->second;

  auto type = IntegerType::get(builder.getContext(), width);
  llvm::APInt resetValue(width, 0);
  if (auto value = resetValues.find(fieldIndex); value != resetValues.end())
    resetValue = value->second.zextOrTrunc(width);
  llvm::APInt zeroValue(width, 0);

  llvm::APInt initialValue = resetValue;
  if (powerOnValue)
    initialValue = powerOnValue->zextOrTrunc(width);
  int style =
      fieldIndex < fieldResetStyle.size() ? fieldResetStyle[fieldIndex]
                                          : resetStyle;
  Value valReg =
      createRegister(fieldIndex * 2, type, resetValue, initialValue, style);
  Value xzReg =
      createRegister(fieldIndex * 2 + 1, type, zeroValue, zeroValue, style);
  LogicValue regs{valReg, xzReg};
  logicRegs[fieldIndex] = regs;
  logicNext[fieldIndex] = regs;
  return regs;
}

LogicalResult CirctModuleEmitter::storeLogicField(unsigned fieldIndex,
                                                 LogicValue value,
                                                 Value condition) {
  if (auto writer = fieldWriter.find(fieldIndex);
      writer != fieldWriter.end() && writer->second != currentMethod)
    return source.emitError()
           << "HDL lowering: field '" << fieldNames[fieldIndex]
           << "' is driven from multiple processes ('"
           << methodNames[writer->second] << "' and '"
           << methodNames[currentMethod] << "')";
  fieldWriter[fieldIndex] = currentMethod;

  LogicValue regs =
      getOrCreateLogicReg(fieldIndex, value.val.getType().getIntOrFloatBitWidth());
  LogicValue hold = logicNext.lookup(fieldIndex);
  LogicValue next = value;
  if (condition && hold) {
    next.val = comb::MuxOp::create(builder, loc, condition, value.val, hold.val);
    next.xz = comb::MuxOp::create(builder, loc, condition, value.xz, hold.xz);
  }
  logicNext[fieldIndex] = next;
  regs.val.getDefiningOp()->setOperand(0, next.val);
  regs.xz.getDefiningOp()->setOperand(0, next.xz);
  return success();
}

/// Bitwise complement at the operand's width.
Value CirctModuleEmitter::bitNot(Value value) {
  unsigned width = value.getType().getIntOrFloatBitWidth();
  auto ones = hw::ConstantOp::create(builder, loc, llvm::APInt::getAllOnes(width));
  return comb::XorOp::create(builder, loc, value, ones);
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

Value CirctModuleEmitter::createRegister(unsigned id, Type type,
                                         llvm::APInt resetValue,
                                         llvm::APInt initialValue, int style) {
  auto zero = hw::ConstantOp::create(builder, loc, type, 0);
  auto resetConstant = hw::ConstantOp::create(builder, loc, resetValue);
  bool activeLow = (style & 1) != 0;
  Value reset = activeLow ? bitNot(resetSignal) : resetSignal;
  bool async = style >= 2;
  if (async) {
    auto name =
        StringAttr::get(builder.getContext(), "reg_" + std::to_string(id));
    return seq::FirRegOp::create(
        builder, loc, zero, clk, name, reset, resetConstant,
        hw::InnerSymAttr(), /*isAsync=*/true,
        /*preset=*/IntegerAttr::get(type, initialValue));
  }
  // Power-on value: the same constructor-derived constant, wrapped in
  // `seq.initial` so it is a true initializer rather than reset logic.
  auto initial = seq::createConstantInitialValue(
      builder, loc, IntegerAttr::get(type, initialValue));
  return seq::CompRegOp::create(builder, loc, zero, clk, reset, resetConstant,
                                initial);
}

Value CirctModuleEmitter::getOrCreateReg(unsigned fieldIndex, Type type) {
  auto found = fieldRegs.find(fieldIndex);
  if (found != fieldRegs.end())
    return found->second;
  unsigned width = type.getIntOrFloatBitWidth();
  llvm::APInt resetValue(width, 0);
  if (auto value = resetValues.find(fieldIndex); value != resetValues.end())
    resetValue = value->second.zextOrTrunc(width);
  llvm::APInt initialValue = resetValue;
  if (powerOnValue)
    initialValue = powerOnValue->zextOrTrunc(width);
  int style =
      fieldIndex < fieldResetStyle.size() ? fieldResetStyle[fieldIndex]
                                          : resetStyle;
  Value reg = createRegister(fieldIndex, type, resetValue, initialValue, style);
  fieldRegs[fieldIndex] = reg;
  fieldNext[fieldIndex] = reg;
  return reg;
}

void CirctModuleEmitter::convertCEToPlain(unsigned fieldIndex) {
  Value reg = fieldRegs.lookup(fieldIndex);
  auto ce = reg ? reg.getDefiningOp<seq::CompRegClockEnabledOp>() : nullptr;
  if (!ce)
    return;
  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPoint(ce);
  Value input = fieldNext.lookup(fieldIndex);
  auto plain = seq::CompRegOp::create(builder, loc, input, clk, ce.getReset(),
                                      ce.getResetValue(),
                                      ce.getInitialValue());
  ce.getResult().replaceAllUsesWith(plain.getResult());
  ce.erase();
  fieldRegs[fieldIndex] = plain;
}

LogicalResult CirctModuleEmitter::storeField(unsigned fieldIndex, Value value,
                                             Value condition) {
  if (auto writer = fieldWriter.find(fieldIndex);
      writer != fieldWriter.end() && writer->second != currentMethod)
    return source.emitError()
           << "HDL lowering: field '" << fieldNames[fieldIndex]
           << "' is driven from multiple processes ('"
           << methodNames[writer->second] << "' and '"
           << methodNames[currentMethod] << "')";
  fieldWriter[fieldIndex] = currentMethod;

  Value reg = getOrCreateReg(fieldIndex, value.getType());
  bool logicField =
      fieldIndex < fieldIsLogic.size() && fieldIsLogic[fieldIndex];
  bool muxed = fieldMuxed.lookup(fieldIndex);

  // Prefer a clock-enabled register when the first write is conditional and
  // every write shares the same enable. Mixed conditions fall back to an
  // input mux.
  if (condition && !logicField && !muxed) {
    if (auto ce = reg.getDefiningOp<seq::CompRegClockEnabledOp>()) {
      Value existing = fieldEnable.lookup(fieldIndex);
      if (existing == condition) {
        ce->setOperand(0, value);
        fieldNext[fieldIndex] = value;
        return success();
      }
      convertCEToPlain(fieldIndex);
      reg = fieldRegs[fieldIndex];
      muxed = true;
      fieldMuxed[fieldIndex] = true;
      fieldEnable.erase(fieldIndex);
    } else if (auto plain = reg.getDefiningOp<seq::CompRegOp>()) {
      if (value != reg) {
        OpBuilder::InsertionGuard guard(builder);
        builder.setInsertionPoint(plain);
        std::string name = "reg_" + std::to_string(fieldIndex);
        auto newReg = seq::CompRegClockEnabledOp::create(
            builder, loc, value, clk, condition, plain.getReset(),
            plain.getResetValue(), name, plain.getInitialValue());
        plain.getResult().replaceAllUsesWith(newReg.getResult());
        plain.erase();
        fieldRegs[fieldIndex] = newReg;
        fieldNext[fieldIndex] = value;
        fieldEnable[fieldIndex] = condition;
        return success();
      }
    }
  }

  // An unconditional write disables any clock enable established earlier.
  if (!condition) {
    if (auto ce = reg.getDefiningOp<seq::CompRegClockEnabledOp>()) {
      convertCEToPlain(fieldIndex);
      fieldEnable.erase(fieldIndex);
      fieldMuxed[fieldIndex] = true;
      reg = fieldRegs[fieldIndex];
    }
  }

  Value hold = fieldNext.lookup(fieldIndex);
  Value next = value;
  if (condition && hold)
    next = comb::MuxOp::create(builder, loc, condition, value, hold);
  fieldNext[fieldIndex] = next;
  reg.getDefiningOp()->setOperand(0, next);
  return success();
}

LogicalResult CirctModuleEmitter::emitOp(Operation *op, Value condition,
                                         Value &returnValue) {
  StringRef name = op->getName().getStringRef();

  if (name == "hlcf.yield")
    return success();

  if (name == "hlcf.if") {
    if (op->getNumOperands() != 1 || op->getNumRegions() != 2 ||
        op->getNumResults() != 0)
      return op->emitError()
             << "HDL lowering: unsupported conditional in HDL method";
    Value cond = getValue(op->getOperand(0));
    if (!cond)
      return op->emitError() << "HDL lowering: condition was not lowered";
    auto hasBody = [](Region &region) {
      if (region.empty())
        return false;
      for (Operation &op : region.front())
        if (op.getName().getStringRef() != "hlcf.yield")
          return true;
      return false;
    };
    Region &thenRegion = op->getRegion(0);
    if (hasBody(thenRegion)) {
      Value thenCond =
          condition ? comb::AndOp::create(builder, loc, condition, cond) : cond;
      if (failed(emitBlock(thenRegion.front(), thenCond, returnValue)))
        return failure();
    }
    Region &elseRegion = op->getRegion(1);
    if (hasBody(elseRegion)) {
      Value notCond = bitNot(cond);
      Value elseCond = condition
                           ? comb::AndOp::create(builder, loc, condition, notCond)
                           : notCond;
      if (failed(emitBlock(elseRegion.front(), elseCond, returnValue)))
        return failure();
    }
    return success();
  }

  if (name == "hlcf.return") {
    if (op->getNumOperands() == 1)
      if (Value value = getValue(op->getOperand(0)))
        returnValue = value;
    // Memory-only results are written through the by-ref result pointer and
    // `return` itself yields `none`.
    if (returnValue)
      return success();
    Operation *valueOp = op->getOperand(0).getDefiningOp();
    if (valueOp && valueOp->getAttrOfType<KGEN::NoneAttr>("value"))
      return success();
    return op->emitError() << "HDL lowering: return value was not lowered";
  }

  if (name == "kgen.param.constant" || name == "pop.constant") {
    if (op->getAttrOfType<KGEN::NoneAttr>("value"))
      return success();
    if (auto value = getConstantBool(op)) {
      values[op->getResult(0)] = getConstant(*value);
      return success();
    }
    if (auto value = getConstantInt(op, &bindings)) {
      intConstants[op->getResult(0)] = *value;
      return success();
    }
    return op->emitError()
           << "HDL lowering: unsupported constant in HDL method";
  }

  if (name == "kgen.call") {
    StringRef callee = callCalleeName(op);

    // A `Mem[W, N]` field becomes N clock-enabled registers plus a read mux.
    if (callee.contains("Mem::write") || callee.contains("Mem::read")) {
      if (op->getNumOperands() < 3)
        return op->emitError() << "HDL lowering: malformed memory access";
      auto mem = fieldPtrs.find(op->getOperand(0));
      if (mem == fieldPtrs.end() || mem->second >= fieldIsMemory.size() ||
          !fieldIsMemory[mem->second])
        return op->emitError()
               << "HDL lowering: memory access on a non-memory field";
      unsigned field = mem->second;
      Value index = getValue(op->getOperand(1));
      if (!index)
        return op->emitError() << "HDL lowering: memory index was not lowered";
      auto &regs = getOrCreateMemory(field);
      if (regs.empty())
        return op->emitError() << "HDL lowering: empty memory";

      if (callee.contains("Mem::write")) {
        if (op->getNumOperands() < 3)
          return op->emitError() << "HDL lowering: malformed memory write";
        Value data = getValue(op->getOperand(2));
        if (!data)
          return op->emitError()
                 << "HDL lowering: memory write data was not lowered";
        Value enable;
        if (op->getNumOperands() > 3) {
          enable = getValue(op->getOperand(3));
          if (!enable)
            return op->emitError()
                   << "HDL lowering: memory write enable was not lowered";
        }
        for (unsigned k = 0; k < regs.size(); ++k) {
          Value eq = comb::ICmpOp::create(
              builder, loc, comb::ICmpPredicate::eq, index,
              hw::ConstantOp::create(builder, loc, index.getType(),
                                     static_cast<int64_t>(k)));
          Value ce = enable
                         ? comb::AndOp::create(builder, loc, enable, eq)
                         : eq;
          if (auto ceOp =
                  regs[k].getDefiningOp<seq::CompRegClockEnabledOp>()) {
            ceOp->setOperand(0, data);
            ceOp->setOperand(2, ce);
          } else if (auto fir = regs[k].getDefiningOp<seq::FirRegOp>()) {
            Value next = comb::MuxOp::create(builder, loc, ce, data, regs[k]);
            fir->setOperand(0, next);
          } else {
            return op->emitError()
                   << "HDL lowering: unsupported memory register form";
          }
        }
        return success();
      }

      Value result = regs[0];
      for (unsigned k = 1; k < regs.size(); ++k) {
        Value eq = comb::ICmpOp::create(
            builder, loc, comb::ICmpPredicate::eq, index,
            hw::ConstantOp::create(builder, loc, index.getType(),
                                   static_cast<int64_t>(k)));
        result = comb::MuxOp::create(builder, loc, eq, regs[k], result);
      }
      Value dest = op->getOperand(2);
      values[dest] = result;
      if (dest == resultPtr)
        returnValue = result;
      return success();
    }

    // A call through a field of another `@module` struct becomes an
    // `hw.instance`: the callee's user inputs are wired from the call
    // operands, ambient clock/reset are forwarded, and the result slot is
    // bound to the instance outputs.
    if (op->getNumOperands() > 0) {
      if (auto instance = instancePtrs.find(op->getOperand(0));
          instance != instancePtrs.end()) {
        unsigned fieldIndex = instance->second;
        Operation *childOp = findBuiltModule(fieldModuleNames[fieldIndex]);
        if (!childOp)
          return op->emitError() << "HDL lowering: instance module '"
                                 << fieldModuleNames[fieldIndex]
                                 << "' was not built";
        auto child = cast<hw::HWModuleOp>(childOp);
        MLIRContext *ctx = source.getContext();
        SmallVector<hw::PortInfo> childInputs;
        for (hw::PortInfo port : child.getPortList())
          if (port.dir == hw::ModulePort::Direction::Input)
            childInputs.push_back(port);

        SmallVector<Value> inputs;
        unsigned operandIndex = 1;
        for (unsigned p = 0; p < childInputs.size(); ++p) {
          hw::PortInfo port = childInputs[p];
          if (isa<seq::ClockType>(port.type)) {
            if (!clk)
              return op->emitError()
                     << "HDL lowering: instance needs a clock";
            inputs.push_back(clk);
            continue;
          }
          if (port.name.getValue() == "rst" ||
              port.name.getValue() == "rst_n") {
            if (!resetSignal)
              return op->emitError() << "HDL lowering: instance needs a reset";
            bool childLow = port.name.getValue() == "rst_n";
            bool parentLow = (resetStyle & 1) != 0;
            Value reset = resetSignal;
            if (childLow != parentLow)
              reset = bitNot(reset);
            inputs.push_back(reset);
            continue;
          }

          // A Logic[W] input is a value/mask port pair driven by one call
          // operand.
          std::string maskName = port.name.getValue().str() + "_xz";
          bool isLogicValue =
              p + 1 < childInputs.size() &&
              childInputs[p + 1].name.getValue() == maskName;
          if (isLogicValue) {
            if (operandIndex + 1 >= op->getNumOperands())
              return op->emitError()
                     << "HDL lowering: too few instance operands";
            LogicValue value = getLogicValue(op->getOperand(operandIndex++));
            if (!value)
              return op->emitError()
                     << "HDL lowering: instance operand was not lowered";
            inputs.push_back(value.val);
            inputs.push_back(value.xz);
            ++p;
            continue;
          }
          if (port.name.getValue().ends_with("_xz"))
            return op->emitError()
                   << "HDL lowering: unmatched Logic mask port '"
                   << port.name.getValue() << "'";

          if (operandIndex + 1 >= op->getNumOperands())
            return op->emitError()
                   << "HDL lowering: too few instance operands";
          Value value = getValue(op->getOperand(operandIndex++));
          if (!value)
            return op->emitError()
                   << "HDL lowering: instance operand was not lowered";
          inputs.push_back(value);
        }
        if (operandIndex + 1 != op->getNumOperands())
          return op->emitError()
                 << "HDL lowering: too many instance operands";
        auto instanceOp = hw::InstanceOp::create(
            builder, loc, childOp,
            StringAttr::get(ctx, fieldNames[fieldIndex]), inputs);
        Value dest = op->getOperand(op->getNumOperands() - 1);
        if (instanceOp.getNumResults() == 1) {
          values[dest] = instanceOp.getResult(0);
          if (dest == resultPtr)
            returnValue = instanceOp.getResult(0);
        } else if (instanceOp.getNumResults() == 2) {
          logicValues[dest] = {instanceOp.getResult(0),
                               instanceOp.getResult(1)};
          if (dest == resultPtr) {
            returnValue = instanceOp.getResult(0);
            returnXz = instanceOp.getResult(1);
            returnIsLogic = true;
          }
        } else {
          return op->emitError()
                 << "HDL lowering: instance with "
                 << instanceOp.getNumResults() << " outputs is not supported";
        }
        return success();
      }
    }

    // `Logic[W]` values are lowered as a (value, xz-mask) pair of `comb`
    // nets. Binary calls take `(lhs, rhs, out-ptr)`, `mux_logic` takes
    // `(cond, a, b, out-ptr)`, and `__invert__` takes `(src, out-ptr)`.
    if (callee.contains("Logic::") || callee.contains("mux_logic")) {
      auto storeResult = [&](Value dest, LogicValue value) -> LogicalResult {
        if (!value)
          return failure();
        if (auto field = fieldPtrs.find(dest);
            field != fieldPtrs.end() &&
            field->second < fieldIsLogic.size() &&
            fieldIsLogic[field->second]) {
          return storeLogicField(field->second, value, condition);
        }
        logicValues[dest] = value;
        if (dest == resultPtr) {
          returnValue = value.val;
          returnXz = value.xz;
          returnIsLogic = true;
        }
        return success();
      };

      if (callee.contains("mux_logic")) {
        if (op->getNumOperands() != 4)
          return op->emitError() << "HDL lowering: unexpected mux_logic form";
        LogicValue cond = getLogicValue(op->getOperand(0));
        LogicValue a = getLogicValue(op->getOperand(1));
        LogicValue b = getLogicValue(op->getOperand(2));
        if (!cond || !a || !b)
          return op->emitError()
                 << "HDL lowering: mux_logic operand was not lowered";
        Value val = comb::MuxOp::create(builder, loc, cond.val, a.val, b.val);
        Value normalXz =
            comb::MuxOp::create(builder, loc, cond.val, a.xz, b.xz);
        Value bothKnown =
            bitNot(comb::OrOp::create(builder, loc, a.xz, b.xz));
        Value equal =
            bitNot(comb::XorOp::create(builder, loc, a.val, b.val));
        Value unknownXz =
            bitNot(comb::AndOp::create(builder, loc, bothKnown, equal));
        Value xz = comb::MuxOp::create(builder, loc, cond.xz, unknownXz,
                                       normalXz);
        return storeResult(op->getOperand(3), {val, xz});
      }

      if (op->getNumOperands() == 3) {
        LogicValue a = getLogicValue(op->getOperand(0));
        LogicValue b = getLogicValue(op->getOperand(1));
        if (!a || !b)
          return op->emitError()
                 << "HDL lowering: Logic operand was not lowered";
        LogicValue result;
        if (callee.contains("::__and__")) {
          Value eitherXz = comb::OrOp::create(builder, loc, a.xz, b.xz);
          Value aKnownOrVal = comb::OrOp::create(builder, loc, a.xz, a.val);
          Value bKnownOrVal = comb::OrOp::create(builder, loc, b.xz, b.val);
          Value xz = comb::AndOp::create(builder, loc, eitherXz, aKnownOrVal);
          result.xz = comb::AndOp::create(builder, loc, xz, bKnownOrVal);
          result.val = comb::AndOp::create(builder, loc, a.val, b.val);
        } else if (callee.contains("::__or__")) {
          Value eitherXz = comb::OrOp::create(builder, loc, a.xz, b.xz);
          Value aUnknownOrNotVal =
              comb::OrOp::create(builder, loc, a.xz, bitNot(a.val));
          Value bUnknownOrNotVal =
              comb::OrOp::create(builder, loc, b.xz, bitNot(b.val));
          Value xz =
              comb::AndOp::create(builder, loc, eitherXz, aUnknownOrNotVal);
          result.xz = comb::AndOp::create(builder, loc, xz, bUnknownOrNotVal);
          result.val = comb::OrOp::create(builder, loc, a.val, b.val);
        } else if (callee.contains("::__xor__")) {
          result.val = comb::XorOp::create(builder, loc, a.val, b.val);
          result.xz = comb::OrOp::create(builder, loc, a.xz, b.xz);
        } else if (callee.contains("::__eq__") ||
                   callee.contains("::__ne__")) {
          // A known difference decides the comparison; otherwise any unknown
          // bit makes the single-bit result unknown (value 0, mask 1).
          Value eitherXz = comb::OrOp::create(builder, loc, a.xz, b.xz);
          Value known = bitNot(eitherXz);
          Value differsBits =
              comb::AndOp::create(builder, loc, known,
                                  comb::XorOp::create(builder, loc, a.val,
                                                      b.val));
          unsigned width = a.val.getType().getIntOrFloatBitWidth();
          auto zero =
              hw::ConstantOp::create(builder, loc, llvm::APInt(width, 0));
          Value differs = comb::ICmpOp::create(
              builder, loc, comb::ICmpPredicate::ne, differsBits, zero);
          Value hasUnknown = comb::ICmpOp::create(
              builder, loc, comb::ICmpPredicate::ne, eitherXz, zero);
          Value notDiffers = bitNot(differs);
          result.xz =
              comb::AndOp::create(builder, loc, hasUnknown, notDiffers);
          if (callee.contains("::__eq__"))
            result.val = comb::AndOp::create(
                builder, loc, notDiffers, bitNot(hasUnknown));
          else
            result.val = differs;
        } else {
          return op->emitError() << "HDL lowering: unsupported Logic call '"
                                 << callee << "'";
        }
        return storeResult(op->getOperand(2), result);
      }

      if (op->getNumOperands() == 2) {
        LogicValue source = getLogicValue(op->getOperand(0));
        if (!source)
          return op->emitError()
                 << "HDL lowering: Logic operand was not lowered";
        if (callee.contains("::__invert__"))
          return storeResult(op->getOperand(1),
                             {bitNot(source.val), source.xz});
        if (callee.contains("Logic::copy") ||
            callee.contains("Logic::__init__"))
          return storeResult(op->getOperand(1), source);
      }

      return op->emitError() << "HDL lowering: unsupported Logic call '"
                             << callee << "'";
    }

    // `Resettable[W, style]` is a Bits value with a register-level reset
    // style; its operations lower exactly like the corresponding Bits ones.
    if (callee.contains("Resettable::")) {
      if (callee.contains("::__deinit__") || callee.contains("::__del__"))
        return success();
      if (callee.contains("::__init__") &&
          !callee.contains("__init__(move:")) {
        unsigned width = getCallParamWidth(op, &bindings);
        Operation *valueOp = op->getOperand(0).getDefiningOp();
        auto value =
            valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
        if (!width || !value)
          return op->emitError()
                 << "HDL lowering: unsupported Resettable constructor";
        Value constant = hw::ConstantOp::create(
            builder, loc, value->zextOrTrunc(width));
        values[op->getOperand(1)] = constant;
        if (op->getOperand(1) == resultPtr)
          returnValue = constant;
        return success();
      }
      if (op->getNumOperands() == 3 && callee.contains("::__add__")) {
        Value lhs = getValue(op->getOperand(0));
        Value rhs = getValue(op->getOperand(1));
        if (!lhs || !rhs)
          return op->emitError()
                 << "HDL lowering: Resettable operand was not lowered";
        Value result = comb::AddOp::create(builder, loc, lhs, rhs);
        values[op->getOperand(2)] = result;
        if (op->getOperand(2) == resultPtr)
          returnValue = result;
        return success();
      }
      if (op->getNumOperands() == 2) {
        Value source = getValue(op->getOperand(0));
        if (!source)
          return op->emitError()
                 << "HDL lowering: Resettable operand was not lowered";
        if (callee.contains("::__init__")) {
          if (op->getOperand(1) == resultPtr) {
            returnValue = source;
          } else if (auto field = fieldPtrs.find(op->getOperand(1));
                     field != fieldPtrs.end()) {
            return storeField(field->second, source, condition);
          } else {
            values[op->getOperand(1)] = source;
          }
          return success();
        }
        if (callee.contains("::get") || callee.contains("::copy")) {
          Value dest = op->getOperand(1);
          values[dest] = source;
          if (dest == resultPtr)
            returnValue = source;
          return success();
        }
      }
      return op->emitError() << "HDL lowering: unsupported Resettable call '"
                             << callee << "'";
    }

    // `Bits[W]` methods lower directly to `comb` ops. The DSL returns values
    // through a stack slot, so a binary call is `(lhs, rhs, out-ptr)`.
    if (callee.contains("Bits::")) {
      // Destructor bookkeeping has no hardware effect.
      if (callee.contains("::__deinit__") || callee.contains("::__del__"))
        return success();
      if (op->getNumOperands() == 3) {
        Value lhs = getValue(op->getOperand(0));
        Value rhs = getValue(op->getOperand(1));
        if (!lhs || !rhs)
          return op->emitError()
                 << "HDL lowering: Bits operand was not lowered";
        Value result;
        if (callee.contains("::__add__"))
          result = comb::AddOp::create(builder, loc, lhs, rhs);
        else if (callee.contains("::__sub__"))
          result = comb::SubOp::create(builder, loc, lhs, rhs);
        else if (callee.contains("::__and__"))
          result = comb::AndOp::create(builder, loc, lhs, rhs);
        else if (callee.contains("::__or__"))
          result = comb::OrOp::create(builder, loc, lhs, rhs);
        else if (callee.contains("::__xor__"))
          result = comb::XorOp::create(builder, loc, lhs, rhs);
        else if (callee.contains("::__eq__"))
          result = comb::ICmpOp::create(builder, loc, comb::ICmpPredicate::eq,
                                        lhs, rhs);
        else if (callee.contains("::__ne__"))
          result = comb::ICmpOp::create(builder, loc, comb::ICmpPredicate::ne,
                                        lhs, rhs);
        else if (callee.contains("::__lt__"))
          result = comb::ICmpOp::create(builder, loc, comb::ICmpPredicate::ult,
                                        lhs, rhs);
        else if (callee.contains("::__le__"))
          result = comb::ICmpOp::create(builder, loc, comb::ICmpPredicate::ule,
                                        lhs, rhs);
        if (!result)
          return op->emitError() << "HDL lowering: unsupported Bits call '"
                                 << callee << "'";
        values[op->getOperand(2)] = result;
        if (op->getOperand(2) == resultPtr)
          returnValue = result;
        return success();
      }
      if (op->getNumOperands() == 2) {
        // `Bits[W](value)` constructs a value from an integer; it becomes a
        // constant of the callee's declared width.
        if (callee.contains("Bits::__init__") &&
            !callee.contains("__init__(move:")) {
          unsigned width = getCallParamWidth(op, &bindings);
          Operation *valueOp = op->getOperand(0).getDefiningOp();
          auto value = valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
          if (!width || !value)
            return op->emitError()
                   << "HDL lowering: unsupported Bits constructor argument";
          Value constant = hw::ConstantOp::create(
              builder, loc, value->zextOrTrunc(width));
          values[op->getOperand(1)] = constant;
          if (op->getOperand(1) == resultPtr)
            returnValue = constant;
          return success();
        }

        Value source = getValue(op->getOperand(0));
        if (!source)
          return op->emitError()
                 << "HDL lowering: Bits operand was not lowered";
        if (callee.contains("::__invert__")) {
          unsigned width = source.getType().getIntOrFloatBitWidth();
          auto ones = hw::ConstantOp::create(builder, loc,
                                             llvm::APInt::getAllOnes(width));
          Value result = comb::XorOp::create(builder, loc, source, ones);
          values[op->getOperand(1)] = result;
          if (op->getOperand(1) == resultPtr)
            returnValue = result;
          return success();
        }
        if (callee.contains("Bits::bit(")) {
          Operation *indexOp = op->getOperand(1).getDefiningOp();
          auto index = indexOp ? getConstantInt(indexOp, &bindings) : std::nullopt;
          if (index && index->isIntN(32)) {
            values[op->getResult(0)] = comb::ExtractOp::create(
                builder, loc, source,
                static_cast<int32_t>(index->getZExtValue()),
                /*bitWidth=*/1);
            return success();
          }
          // Dynamic select: shift the requested bit down to bit zero.
          Value indexValue = getValue(op->getOperand(1));
          if (!indexValue)
            return op->emitError()
                   << "HDL lowering: Bits::bit index was not lowered";
          unsigned width = source.getType().getIntOrFloatBitWidth();
          unsigned indexWidth = indexValue.getType().getIntOrFloatBitWidth();
          if (indexWidth > width) {
            indexValue =
                comb::ExtractOp::create(builder, loc, indexValue, 0, width);
          } else if (indexWidth < width) {
            auto zeros = hw::ConstantOp::create(
                builder, loc, llvm::APInt(width - indexWidth, 0));
            indexValue = comb::ConcatOp::create(
                builder, loc, ArrayRef<Value>{zeros, indexValue});
          }
          Value shifted =
              comb::ShrUOp::create(builder, loc, source, indexValue);
          values[op->getResult(0)] =
              comb::ExtractOp::create(builder, loc, shifted, 0, 1);
          return success();
        }
        if (callee.contains("Bits::__init__")) {
          // Move the computed value into a result slot or a state field.
          if (op->getOperand(1) == resultPtr) {
            returnValue = source;
          } else if (auto field = fieldPtrs.find(op->getOperand(1));
                     field != fieldPtrs.end()) {
            return storeField(field->second, source, condition);
          } else {
            values[op->getOperand(1)] = source;
          }
          return success();
        }
        if (callee.contains("Bits::copy")) {
          if (op->getOperand(1) == resultPtr)
            returnValue = source;
          else
            values[op->getOperand(1)] = source;
          return success();
        }
      }
      return op->emitError() << "HDL lowering: unsupported Bits call '" << callee
                             << "'";
    }

    Value operand = op->getNumOperands() == 1 ? getValue(op->getOperand(0))
                                              : Value();
    if (callee.contains("::__bool__") || callee.contains("__mlir_bool__")) {
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
    unsigned field = index.getInt();
    if (field < fieldIsInstance.size() && fieldIsInstance[field])
      instancePtrs[op->getResult(0)] = field;
    else
      fieldPtrs[op->getResult(0)] = field;
    return success();
  }

  if (name == "pop.store") {
    Value stored = getValue(op->getOperand(0));
    if (!stored)
      return op->emitError() << "HDL lowering: stored value was not lowered";
    auto field = fieldPtrs.find(op->getOperand(1));
    if (field != fieldPtrs.end())
      return storeField(field->second, stored, condition);
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
  return emitBlock(entry, /*condition=*/Value(), returnValue);
}

LogicalResult CirctModuleEmitter::emitBlock(Block &block, Value condition,
                                            Value &returnValue) {
  for (Operation &op : block.getOperations())
    if (failed(emitOp(&op, condition, returnValue)))
      return failure();
  return success();
}

LogicalResult CirctModuleEmitter::build() {
  if (failed(findMethods()) || failed(collectFieldWidths()) ||
      failed(collectResetValues()) || failed(collectMethodDomains()) ||
      failed(collectPorts()))
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

  // One ambient clock/reset pair per stateful method (domain root).
  for (unsigned m = 0; m < methods.size(); ++m) {
    if (!methodHasState[m])
      continue;
    bool single = methods.size() == 1;
    std::string clkName = single ? "clk" : "clk_" + methodNames[m];
    std::string rstBase = (resetStyle & 1) ? "rst_n" : "rst";
    std::string rstName =
        single ? rstBase : rstBase + "_" + methodNames[m];

    hw::PortInfo clkInfo;
    clkInfo.name = StringAttr::get(ctx, clkName);
    clkInfo.type = seq::ClockType::get(ctx);
    clkInfo.dir = hw::ModulePort::Direction::Input;
    clkInfo.argNum = inputs.size();
    inputs.push_back(clkInfo);

    hw::PortInfo resetInfo;
    resetInfo.name = StringAttr::get(ctx, rstName);
    resetInfo.type = IntegerType::get(ctx, 1);
    resetInfo.dir = hw::ModulePort::Direction::Input;
    resetInfo.argNum = inputs.size();
    inputs.push_back(resetInfo);
  }

  builder.setInsertionPointToEnd(scratch.getBody());
  builtModule = hw::HWModuleOp::create(
      builder, loc, StringAttr::get(ctx, moduleName),
      hw::ModulePortInfo(inputs, outputs));

  Block *body = builtModule.getBodyBlock();
  size_t portIndex = 0;

  // Map every method's user inputs and remember its `self`/result slots. All
  // user inputs come before the per-domain clock/reset pairs.
  SmallVector<Value> selfArgs(methods.size());
  SmallVector<Value> resultArgs(methods.size());
  for (unsigned m = 0; m < methods.size(); ++m) {
    auto func = cast<FunctionOpInterface>(methods[m]);
    auto sourceFunc = getSourceFuncType(methods[m]);
    Block &entry = func.getFunctionBody().front();
    unsigned argIndex = 0;
    for (BlockArgument arg : entry.getArguments()) {
      unsigned index = argIndex++;
      if (index == 0) {
        selfArgs[m] = arg;
        continue;
      }
      if (sourceFunc && sourceFunc.getArgConvention(index) ==
                            ArgConvention::ByRefResult) {
        resultArgs[m] = arg;
        continue;
      }
      Type sourceType =
          sourceFunc ? sourceFunc.getArgument(index) : arg.getType();
      if (isLogicType(sourceType)) {
        logicValues[arg] = {body->getArgument(portIndex),
                            body->getArgument(portIndex + 1)};
        portIndex += 2;
      } else {
        values[arg] = body->getArgument(portIndex++);
      }
    }
  }

  SmallVector<Value> domainClk(methods.size());
  SmallVector<Value> domainReset(methods.size());
  for (unsigned m = 0; m < methods.size(); ++m) {
    if (!methodHasState[m])
      continue;
    domainClk[m] = body->getArgument(portIndex++);
    domainReset[m] = body->getArgument(portIndex++);
  }

  SmallVector<Value> outputValues;
  for (unsigned m = 0; m < methods.size(); ++m) {
    currentMethod = m;
    selfPtr = selfArgs[m];
    resultPtr = resultArgs[m];
    clk = domainClk[m];
    resetSignal = domainReset[m];
    returnIsLogic = false;
    returnXz = Value();

    Value returnValue;
    builder.setInsertionPoint(body->getTerminator());
    if (failed(emitOps(methods[m], returnValue)))
      return failure();
    if (methodOutputCounts[m] == 0)
      continue;
    if (!returnValue || (returnIsLogic && !returnXz))
      return methods[m]->emitError()
             << "HDL lowering: no value for module output";
    outputValues.push_back(returnValue);
    if (returnIsLogic)
      outputValues.push_back(returnXz);
  }

  // Report cross-domain reads after every method has been seen, so method
  // order does not matter.
  for (auto &[field, readers] : fieldReaders) {
    auto writer = fieldWriter.find(field);
    if (writer == fieldWriter.end())
      continue;
    for (unsigned reader : readers)
      if (reader != writer->second)
        return source.emitError()
               << "HDL lowering: field '" << fieldNames[field]
               << "' is read from process '" << methodNames[reader]
               << "' but driven from '" << methodNames[writer->second] << "'";
  }

  auto output = cast<hw::OutputOp>(body->getTerminator());
  output->setOperands(outputValues);
  return success();
}

/// Return the concretized type of a `@module` struct declaration.
static KGEN::StructInstanceType getStructInstanceType(ModuleOp source,
                                                      StringRef name) {
  for (Operation &op : source.getBody()->getOperations()) {
    auto symbol = op.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (!symbol || symbol.getValue() != name)
      continue;
    if (auto generator = dyn_cast<KGEN::StructGeneratorOp>(&op))
      return dyn_cast<StructInstanceType>(generator.getValueDomainType());
  }
  return {};
}

struct ModuleSpec {
  std::string structName;
  std::string displayName;
  ParamBindings bindings;
};

static KGEN::StructGeneratorOp findStructGenerator(ModuleOp source,
                                                   StringRef name) {
  for (Operation &op : source.getBody()->getOperations()) {
    auto symbol = op.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (!symbol || symbol.getValue() != name)
      continue;
    if (auto generator = dyn_cast<KGEN::StructGeneratorOp>(&op))
      return generator;
  }
  return {};
}

/// Discover concrete module specializations and order them children-first.
static SmallVector<ModuleSpec> collectModuleSpecs(ModuleOp source,
                                                  ArrayAttr modules) {
  llvm::StringSet<> known;
  for (Attribute attr : modules)
    known.insert(cast<StringAttr>(attr).getValue());

  using BindingTuple = std::vector<int64_t>;

  // Concrete binding tuples referenced by a struct field somewhere in the
  // design.
  std::map<std::string, std::set<BindingTuple>> discovered;
  for (Attribute attr : modules) {
    auto parentType = getStructInstanceType(source,
                                           cast<StringAttr>(attr).getValue());
    if (!parentType)
      continue;
    for (StructDefFieldAttr field : parentType.getFields()) {
      Type fieldType = getTypeFromAttr(field.getTypeValue());
      std::string child = getDslTypeName(fieldType).str();
      if (!known.contains(child))
        continue;
      auto bindings = getDslTypeBindings(fieldType);
      if (bindings.empty())
        continue;
      BindingTuple tuple;
      for (auto binding : bindings)
        tuple.push_back(binding.getZExtValue());
      discovered[child].insert(tuple);
    }
  }

  std::map<std::string, ModuleSpec> specs;
  for (Attribute attr : modules) {
    std::string name = cast<StringAttr>(attr).getValue().str();
    auto generator = findStructGenerator(source, name);
    std::string unqualified = StringRef(name).rsplit("::").second.str();
    if (!generator || generator.getInputParams().empty()) {
      specs[unqualified] = ModuleSpec{name, unqualified, ParamBindings()};
      continue;
    }
    auto params = generator.getInputParams();
    for (const BindingTuple &tuple : discovered[name]) {
      ModuleSpec spec;
      spec.structName = name;
      spec.displayName = unqualified;
      for (unsigned i = 0; i < tuple.size() && i < params.size(); ++i) {
        spec.displayName += "_" + std::to_string(tuple[i]);
        StringRef paramName = params[i].getName().getValue();
        spec.bindings[paramName] = llvm::APInt(64, tuple[i]);
        // The lowered body refers to struct parameters by index (for example
        // `*(0, 0)`), so bind indices as well.
        spec.bindings["#" + std::to_string(i)] = llvm::APInt(64, tuple[i]);
      }
      specs[spec.displayName] = spec;
    }
  }

  std::map<std::string, SmallVector<std::string>> edges;
  for (auto &[key, spec] : specs) {
    auto type = getStructInstanceType(source, spec.structName);
    if (!type)
      continue;
    for (StructDefFieldAttr field : type.getFields()) {
      Type fieldType = getTypeFromAttr(field.getTypeValue());
      std::string child = getDslTypeName(fieldType).str();
      if (!known.contains(child))
        continue;
      std::string childDisplay = StringRef(child).rsplit("::").second.str();
      for (auto binding : getDslTypeBindings(fieldType, &spec.bindings))
        childDisplay += "_" + std::to_string(binding.getZExtValue());
      if (specs.contains(childDisplay))
        edges[key].push_back(childDisplay);
    }
  }

  SmallVector<ModuleSpec> order;
  llvm::StringSet<> done;
  std::function<void(const std::string &)> visit =
      [&](const std::string &key) {
        if (!done.insert(key).second)
          return;
        auto edge = edges.find(key);
        if (edge != edges.end())
          for (const std::string &child : edge->second)
            visit(child);
        auto spec = specs.find(key);
        if (spec != specs.end())
          order.push_back(spec->second);
      };
  for (auto &[key, spec] : specs)
    visit(key);
  return order;
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
    for (const ModuleSpec &spec : collectModuleSpecs(module, modules)) {
      CirctModuleEmitter emitter(module, spec.structName, spec.displayName,
                                 spec.bindings, *scratch, modules);
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
