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
#include "circt/Dialect/SV/SVDialect.h"
#include "circt/Dialect/SV/SVOps.h"
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
#include "mlir/IR/PatternMatch.h"
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

static std::optional<bool>
getTypedAttrBool(TypedAttr attr, const ParamBindings *bindings);

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
    auto operands = expr.getOperands();

    if (opcode == KGEN::POC::Add || opcode == KGEN::POC::Mul ||
        opcode == KGEN::POC::MulNoWrap || opcode == KGEN::POC::Max ||
        opcode == KGEN::POC::Min) {
      if (operands.empty())
        return std::nullopt;
      auto first = getTypedAttrInt(operands[0], bindings);
      if (!first)
        return std::nullopt;
      llvm::APInt accum = first->zextOrTrunc(64);
      for (unsigned i = 1; i < operands.size(); ++i) {
        auto value = getTypedAttrInt(operands[i], bindings);
        if (!value)
          return std::nullopt;
        auto bits = value->zextOrTrunc(64);
        if (opcode == KGEN::POC::Add)
          accum += bits;
        else if (opcode == KGEN::POC::Mul || opcode == KGEN::POC::MulNoWrap)
          accum *= bits;
        else if (opcode == KGEN::POC::Max)
          accum = accum.ugt(bits) ? accum : bits;
        else
          accum = accum.ult(bits) ? accum : bits;
      }
      return accum;
    }

    if ((opcode == KGEN::POC::Div || opcode == KGEN::POC::DivS ||
         opcode == KGEN::POC::DivU || opcode == KGEN::POC::Mod ||
         opcode == KGEN::POC::FloorDivS || opcode == KGEN::POC::RemS ||
         opcode == KGEN::POC::RemU) &&
        operands.size() == 2) {
      auto lhs = getTypedAttrInt(operands[0], bindings);
      auto rhs = getTypedAttrInt(operands[1], bindings);
      if (!lhs || !rhs || rhs->isZero())
        return std::nullopt;
      auto a = lhs->zextOrTrunc(64);
      auto b = rhs->zextOrTrunc(64);
      if (opcode == KGEN::POC::Div)
        return a.udiv(b);
      if (opcode == KGEN::POC::DivS || opcode == KGEN::POC::FloorDivS)
        return a.sdiv(b);
      if (opcode == KGEN::POC::Mod || opcode == KGEN::POC::RemU)
        return a.urem(b);
      return a.srem(b);
    }

    if (opcode == KGEN::POC::Cond && operands.size() == 3) {
      auto cond = getTypedAttrBool(operands[0], bindings);
      if (!cond)
        return std::nullopt;
      return getTypedAttrInt(operands[(*cond) ? 1 : 2], bindings);
    }

    if (opcode == KGEN::POC::Apply && operands.size() >= 3) {
      auto func = KGEN::FuncSymbolGenerator::dynCast(operands[0]);
      auto name = func ? func.getSymbol().getLeafReference().getValue()
                       : StringRef();
      auto lhs = getTypedAttrInt(operands[1], bindings);
      auto rhs = getTypedAttrInt(operands[2], bindings);
      if (!lhs || !rhs || rhs->isZero())
        return std::nullopt;
      auto a = lhs->zextOrTrunc(64);
      auto b = rhs->zextOrTrunc(64);
      if (name.contains("__floordiv__"))
        return a.udiv(b);
      if (name.contains("__ceildiv__"))
        return a.udiv(b) + (a.urem(b).isZero() ? 0 : 1);
      if (name.contains("__mod__"))
        return a.urem(b);
      if (name.contains("__mul__"))
        return a * b;
      if (name.contains("__add__"))
        return a + b;
      return std::nullopt;
    }
    return std::nullopt;
  }
  return std::nullopt;
}

static std::optional<bool>
getTypedAttrBool(TypedAttr attr, const ParamBindings *bindings) {
  if (!attr)
    return std::nullopt;
  if (auto simd = dyn_cast<KGEN::SIMDAttr>(attr)) {
    if (simd.getType().getResolvedSize() == 1 &&
        simd.getType().getResolvedDType() == KGENDType::kBool)
      return simd.getAsBool();
  }
  if (auto intAttr = dyn_cast<IntegerAttr>(attr))
    if (intAttr.getType().isInteger(1))
      return intAttr.getValue().getBoolValue();

  if (auto ident = dyn_cast<KGEN::ParamIdenticalAttr>(attr)) {
    auto operands = ident.getOperands();
    if (operands.size() < 2)
      return std::nullopt;
    auto lhs = getTypedAttrInt(operands[0], bindings);
    auto rhs = getTypedAttrInt(operands[1], bindings);
    if (lhs && rhs)
      return lhs->zextOrTrunc(64) == rhs->zextOrTrunc(64);
    auto lhsBool = getTypedAttrBool(operands[0], bindings);
    auto rhsBool = getTypedAttrBool(operands[1], bindings);
    if (lhsBool && rhsBool)
      return *lhsBool == *rhsBool;
    return std::nullopt;
  }

  auto expr = dyn_cast<KGEN::ParamOperatorAttr>(attr);
  if (!expr)
    return std::nullopt;
  auto opcode = expr.getOpcode();
  auto operands = expr.getOperands();
  if ((opcode == KGEN::POC::EQ || opcode == KGEN::POC::LT ||
       opcode == KGEN::POC::LE) &&
      operands.size() == 2) {
    auto lhs = getTypedAttrInt(operands[0], bindings);
    auto rhs = getTypedAttrInt(operands[1], bindings);
    if (!lhs || !rhs)
      return std::nullopt;
    auto a = lhs->zextOrTrunc(64);
    auto b = rhs->zextOrTrunc(64);
    if (opcode == KGEN::POC::EQ)
      return a == b;
    if (opcode == KGEN::POC::LT)
      return a.ult(b);
    return a.ule(b);
  }
  if ((opcode == KGEN::POC::And || opcode == KGEN::POC::Or ||
       opcode == KGEN::POC::Xor) &&
      !operands.empty()) {
    bool accum = opcode == KGEN::POC::And;
    for (TypedAttr operand : operands) {
      auto value = getTypedAttrBool(operand, bindings);
      if (!value)
        return std::nullopt;
      if (opcode == KGEN::POC::And)
        accum = accum && *value;
      else if (opcode == KGEN::POC::Or)
        accum = accum || *value;
      else
        accum = accum != *value;
    }
    return accum;
  }
  if (opcode == KGEN::POC::Cond && operands.size() == 3) {
    auto cond = getTypedAttrBool(operands[0], bindings);
    if (!cond)
      return std::nullopt;
    return getTypedAttrBool(operands[(*cond) ? 1 : 2], bindings);
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

static Type getDslTypeParam(Type type, unsigned index);

static bool isLogicType(Type type) {
  StringRef name = getDslTypeName(type);
  if (name.contains("Logic"))
    return true;
  if (name.contains("Packed") || name.ends_with("Array")) {
    Type element = getDslTypeParam(type, 0);
    return element && isLogicType(element);
  }
  return false;
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
    if (ref && (name.contains("Packed") || name.ends_with("Array"))) {
      auto params = ref.getParamValues();
      if (params.size() >= 2) {
        auto elemRef = KGEN::getTypeRefForTypeValueIfResolved(params[0]);
        Type elem = elemRef ? KGEN::TypeValueType::get(elemRef) : Type();
        auto depth = getTypedAttrInt(params[1], bindings);
        if (elem && depth)
          return getHdlWidth(elem, bindings) * depth->getZExtValue();
      }
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

/// Return the type bound to DSL reference parameter `index`, if it is a type.
static Type getDslTypeParam(Type type, unsigned index) {
  if (auto ptr = dyn_cast<KGEN::PointerType>(type))
    type = ptr.getElementType();
  auto typeValue = dyn_cast<KGEN::TypeValueType>(type);
  if (!typeValue)
    return {};
  auto ref = dyn_cast<KGEN::TypeGeneratorRefAttr>(typeValue.getTypeValue());
  if (!ref || index >= ref.getParamValues().size())
    return {};
  auto resolved =
      KGEN::getTypeRefForTypeValueIfResolved(ref.getParamValues()[index]);
  return resolved ? KGEN::TypeValueType::get(resolved) : Type();
}

/// Return the integer bound to DSL reference parameter `index`, if present.
static std::optional<llvm::APInt>
getDslTypeIntParam(Type type, unsigned index,
                   const ParamBindings *bindings = nullptr) {
  if (auto ptr = dyn_cast<KGEN::PointerType>(type))
    type = ptr.getElementType();
  auto typeValue = dyn_cast<KGEN::TypeValueType>(type);
  if (!typeValue)
    return std::nullopt;
  auto ref = dyn_cast<KGEN::TypeGeneratorRefAttr>(typeValue.getTypeValue());
  if (!ref || index >= ref.getParamValues().size())
    return std::nullopt;
  return getTypedAttrInt(ref.getParamValues()[index], bindings);
}

/// Return the type bound to the method symbol's parameter `index`.
static Type getCallTypeParam(Operation *op, unsigned index) {
  auto symbol = KGEN::FuncSymbolGenerator::dynCast(op->getAttr("callee"));
  if (!symbol)
    return {};
  auto params = symbol.getParamValues();
  if (index >= params.size())
    return {};
  auto resolved = KGEN::getTypeRefForTypeValueIfResolved(params[index]);
  return resolved ? KGEN::TypeValueType::get(resolved) : Type();
}

/// Return the integer bound to the method symbol's parameter `index`.
static std::optional<llvm::APInt>
getCallIntParam(Operation *op, unsigned index,
                const ParamBindings *bindings = nullptr) {
  auto symbol = KGEN::FuncSymbolGenerator::dynCast(op->getAttr("callee"));
  if (!symbol)
    return std::nullopt;
  auto params = symbol.getParamValues();
  if (index >= params.size())
    return std::nullopt;
  return getTypedAttrInt(params[index], bindings);
}

/// Return the total width of a `Packed[T, N]` method binding.
static unsigned getCallPackedWidth(Operation *op,
                                   const ParamBindings *bindings = nullptr) {
  Type elem = getCallTypeParam(op, 0);
  auto depth = getCallIntParam(op, 1, bindings);
  if (!elem || !depth)
    return 0;
  return getHdlWidth(elem, bindings) * depth->getZExtValue();
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

  /// Collect the methods that can run as native-Sim processes: a `mut self`
  /// method with no other arguments and no result. This is compiler-level
  /// discovery over the elaborated signatures, independent of source comments.
  LogicalResult collectProcesses(SmallVectorImpl<std::string> &processes);

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
  /// The ambient clock name of a process domain, or "combinational" when the
  /// method has no state of its own.
  std::string domainName(unsigned method) const;
  /// Lower a runtime-bounded `while` loop one iteration per clock. Sets
  /// `handled` when the loop matches; otherwise leaves the IR untouched so the
  /// constant-unroll path can run.
  LogicalResult emitDynamicLoop(Operation *loop, Value condition,
                                Value &returnValue, bool &handled);
  /// Lower a runtime-bounded `for i in range(n)` loop one iteration per clock.
  LogicalResult emitRuntimeRangeLoop(Operation *loop, Value condition,
                                     Value &returnValue, bool &handled);
  /// Lower a runtime range loop nested inside another runtime loop.
  LogicalResult emitNestedRangeLoop(Operation *loop, Value condition,
                                    Value &returnValue, bool &handled);
  LogicalResult emitOps(Operation *fn, Value &returnValue);
  LogicalResult emitBlock(Block &block, Value condition, Value &returnValue);
  LogicalResult emitOp(Operation *op, Value condition, Value &returnValue);
  LogicalResult storeField(unsigned fieldIndex, Value value, Value condition);
  void convertCEToPlain(unsigned fieldIndex, bool preserveEnable = true);
  Operation *findBuiltModule(StringRef name);
  Value getValue(Value value);
  LogicValue getLogicValue(Value value);
  LogicValue getOrCreateLogicReg(unsigned fieldIndex, unsigned width);
  LogicalResult storeLogicField(unsigned fieldIndex, LogicValue value,
                                Value condition);
  Value bitNot(Value value);
  Value getConstant(bool value);
  Value getOrCreateReg(unsigned fieldIndex, Type type);
  SmallVector<Value> &getOrCreateArrayStorage(unsigned fieldIndex);
  Value getOrCreateHLMem(unsigned fieldIndex);
  Value getOrCreateArrayRam(unsigned fieldIndex);
  /// Fill per-entry reset and power-on values for a memory field. Returns true
  /// when any value is nonzero (and therefore needs explicit initialization).
  bool collectMemoryInit(unsigned fieldIndex, unsigned width, unsigned depth,
                         SmallVectorImpl<llvm::APInt> &reset,
                         SmallVectorImpl<llvm::APInt> &poweron);
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
  DenseMap<unsigned, unsigned> instanceMethod;

  // A branch literal is one `if` condition together with the polarity of the
  // branch being emitted. Two call sites are mutually exclusive when their
  // paths contain the same condition with opposite polarity.
  struct BranchLiteral {
    Value cond;
    bool positive;
  };
  struct InstanceCallState {
    Operation *op = nullptr;
    unsigned results = 0;
    SmallVector<SmallVector<BranchLiteral>> paths;
  };
  static bool pathsExclusive(ArrayRef<BranchLiteral> lhs,
                             ArrayRef<BranchLiteral> rhs) {
    for (const BranchLiteral &a : lhs)
      for (const BranchLiteral &b : rhs)
        if (a.cond == b.cond && a.positive != b.positive)
          return true;
    return false;
  }
  DenseMap<unsigned, InstanceCallState> instanceCalls;
  // Runtime-bounded loop time-multiplexing: one iteration per clock. The
  // induction variable is a register and body effects are gated by its
  // in-range condition.
  bool inDynamicLoop = false;
  Value dynamicLoopSlot;
  unsigned loopRegisterId = 4096;
  // Stack slots allocated before the runtime loop. Writing one inside the
  // loop would be a loop-carried local, which this lowering does not model.
  SmallVector<Value> stackSlots;
  SmallVector<Value> dynamicLoopOuterSlots;
  bool isLoopCarriedSlot(Value value) const;

  // Plain Mojo struct locals are memory-only. Each field GEP becomes a
  // synthetic carried slot so the loop/register machinery can treat fields
  // like scalar locals. Aliases canonicalize repeated GEPs to one slot.
  struct StructFieldInit {
    Value val;
    Value xz;
  };
  // A nested field access is a chain of GEPs. Keep the index path and the
  // root stack slot so every chain to the same leaf shares one carried slot.
  struct StructFieldPath {
    Value root;
    SmallVector<unsigned> path;
  };
  DenseMap<Value, StructFieldPath> structFieldPaths;
  DenseMap<Value, SmallVector<std::pair<SmallVector<unsigned>, Value>>>
      structFieldSlots;
  DenseMap<Value, Value> structFieldAliases;
  DenseMap<Value, SmallVector<std::pair<unsigned, StructFieldInit>>>
      structFieldInits;
  Value getStructFieldSlot(Operation *gep, Value root,
                           ArrayRef<unsigned> path);
  std::optional<StructFieldPath> resolveStructFieldPath(Value base,
                                                        unsigned index) const;
  Value resolveStructField(Value value) const;
  LogicalResult emitStructConstructor(Operation *op, StringRef callee,
                                      Value condition,
                                      Value &returnValue);
  LogicalResult emitStructMethod(Operation *op, StringRef callee,
                                Value condition, Value &returnValue);
  Operation *findFunction(StringRef name);
  // One-cycle pulse after a runtime loop completes. Subsequent ops in the
  // same block are gated by it, so post-loop code runs once per traversal.
  Value pendingLoopDone;
  // The done pulse that started the next loop; distinguishes sequencing from
  // an ordinary enclosing condition.
  Value currentStartPulse;

  // Locals read and written across a runtime loop become registers. The value
  // is loaded from the pre-loop source during the init/done cycle and updated
  // under the loop's active condition.
  DenseMap<Value, Value> loopCarriedRegs;
  DenseMap<Value, Value> loopCarriedNext;
  DenseMap<Value, Value> loopCarriedInit;
  DenseMap<Value, LogicValue> loopCarriedLogicRegs;
  DenseMap<Value, LogicValue> loopCarriedLogicNext;
  DenseMap<Value, LogicValue> loopCarriedLogicInit;
  Value loopRunning;
  // One level of runtime-loop nesting.
  // Completion of a loop nested in the current body; each nesting level
  // computes its own last and propagates it to its parent.
  Value childLoopLast;
  bool childLoopRan = false;
  // A runtime `break` inside a conditional becomes a loop-exit condition.
  // `loopRelativeCondition` is the AND of enclosing if conditions inside the
  // current loop, excluding the loop's own active condition.
  Value dynamicBreakCond;
  Value loopRelativeCondition;
  // True while emitting a runtime loop that is followed by another runtime
  // loop in the same block. Its carried state is kept for the next loop.
  bool loopFollowedByLoop = false;
  // Per-slot carried registers of the first loop in a sequence. The last
  // loop patches each next value so the whole sequence restarts.
  struct SequenceCarried {
    Value slot;
    Value reg;
    Value next;
    Value init;
  };
  struct SequenceCarriedLogic {
    Value slot;
    Value valReg;
    Value valNext;
    Value valInit;
    Value xzReg;
    Value xzNext;
    Value xzInit;
  };
  struct SequenceState {
    bool active = false;
    Value running;
    Value runningNext;
    Value counter;
    Value counterNext;
    SmallVector<SequenceCarried> carried;
    SmallVector<SequenceCarriedLogic> logic;
  };
  SequenceState sequence;
  SmallVector<Value> collectLoopCarriedSlots(Block &block,
                                             Value inductionSlot);
  bool storeLoopCarried(Value slot, Value value, Value condition);
  bool storeLoopCarriedLogic(Value slot, LogicValue value, Value condition);

  // Direct `self.child.<field>` accesses, diagnosed after every process has
  // been seen so the owning domain is known regardless of method order.
  struct ChildFieldAccess {
    unsigned member;
    unsigned method;
  };
  DenseMap<unsigned, SmallVector<ChildFieldAccess>> childFieldAccesses;
  SmallVector<BranchLiteral> branchPath;
  // One result binding, in emission order. The condition is the branch path
  // that produced it; `xz` is set for a four-state result. Sites are folded
  // into one mux tree after the method body.
  struct ReturnSite {
    Value condition;
    Value value;
    Value xz;
  };
  SmallVector<ReturnSite> returnSites;

  // Statically-unrolled `hlcf.loop` support. A `while` loop with a constant
  // bound is unrolled by evaluating its control path; a stateful child may not
  // tick more than once per clock and is diagnosed by the instance checks.
  struct LoopControl {
    bool breakTaken = false;
    bool continueTaken = false;
  };
  SmallVector<LoopControl> loopStack;
  bool inLoopUnroll = false;
  // Constants currently held in stack slots, used to evaluate loop control.
  DenseMap<Value, llvm::APInt> slotConstants;
  std::optional<llvm::APInt> resolveConstant(Value value);

  // A `range(n)` iterator is unrolled symbolically: `rangeValues` carries the
  // bounds through stack slots and `rangeNext` is the next induction value.
  struct RangeValue {
    uint64_t start;
    uint64_t stop;
    Value runtimeBound;
  };
  DenseMap<Value, RangeValue> rangeValues;
  DenseMap<Value, uint64_t> rangeNext;
  std::optional<RangeValue> resolveRange(Value value);

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
  SmallVector<bool> fieldIsArrayStorage;
  SmallVector<bool> fieldIsWire;
  SmallVector<unsigned> fieldArrayWidths;
  SmallVector<unsigned> fieldArrayDepths;
  SmallVector<int> fieldResetStyle;
  DenseMap<unsigned, SmallVector<Value>> arrayRegs;
  DenseMap<unsigned, SmallVector<Value>> arrayNext;
  DenseMap<unsigned, SmallVector<Value>> arrayXzRegs;
  DenseMap<unsigned, SmallVector<Value>> arrayXzNext;
  DenseMap<unsigned, SmallVector<Value>> arrayEnable;
  DenseMap<unsigned, SmallVector<bool>> arrayWritten;
  DenseMap<unsigned, bool> arrayIsLogic;
  DenseMap<unsigned, bool> arrayIsExplicitRam;
  DenseMap<unsigned, bool> arrayIsArrayRam;
  DenseMap<unsigned, Value> hlMemOps;
  DenseMap<unsigned, Value> arrayRamRegs;
  DenseMap<unsigned, bool> arrayRamWritten;
  DenseMap<unsigned, Value> wireValues;
  struct ArrayElementAccess {
    unsigned field;
    Value index;
  };
  DenseMap<Value, ArrayElementAccess> arrayElements;
  struct DelayedNext {
    unsigned field;
    unsigned delay;
    Value elementIndex;
    bool isArrayElement;
  };
  DenseMap<Value, DelayedNext> delayedTargets;
  DenseMap<unsigned, SmallVector<Value>> delayedNextRegs;
  DenseMap<unsigned, SmallVector<LogicValue>> delayedLogicNextRegs;
  DenseMap<unsigned, std::map<unsigned, SmallVector<Value>>> pastChains;
  DenseMap<unsigned, std::map<unsigned, SmallVector<LogicValue>>>
      pastLogicChains;
  DenseMap<unsigned, SmallVector<llvm::APInt>> arrayResetSequences;
  int resetStyle = 0;
  int clockDivisor = 1;
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
      if (field < fieldIsWire.size() && fieldIsWire[field])
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

Operation *CirctModuleEmitter::findFunction(StringRef name) {
  for (Operation &candidate : source.getBody()->getOperations()) {
    auto symbol =
        candidate.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (symbol && symbol.getValue() == name)
      return &candidate;
  }
  return nullptr;
}

LogicalResult CirctModuleEmitter::emitStructMethod(Operation *op,
                                                   StringRef callee,
                                                   Value condition,
                                                   Value &returnValue) {
  Operation *method = findFunction(callee);
  if (!method)
    return op->emitError()
           << "HDL lowering: struct method '" << callee << "' was not found";
  auto func = dyn_cast<FunctionOpInterface>(method);
  if (!func || func.getFunctionBody().empty())
    return op->emitError() << "HDL lowering: struct method has no body";
  Block &body = func.getFunctionBody().front();

  // Substitute the method's entry arguments with the call operands. A method
  // takes `self` first; the inliner only handles straight-line bodies.
  DenseMap<Value, Value> subst;
  for (unsigned i = 0; i < body.getNumArguments(); ++i) {
    if (i >= op->getNumOperands())
      return op->emitError()
             << "HDL lowering: struct method argument was not lowered";
    subst[body.getArgument(i)] = op->getOperand(i);
  }

  // A value-returning method writes its result through the last entry
  // argument (the hidden by-ref result slot). Route those writes through
  // return sites and fold them into one value for the caller.
  bool isConstructor = callee.split('(').first.ends_with("::__init__");
  Value resultSlot;
  if (!isConstructor && body.getNumArguments() > 0) {
    auto mapped = subst.find(body.getArgument(body.getNumArguments() - 1));
    if (mapped != subst.end())
      resultSlot = mapped->second;
  }
  Value savedResultPtr = resultPtr;
  Value savedReturnValue = returnValue;
  bool savedReturnIsLogic = returnIsLogic;
  Value savedReturnXz = returnXz;
  auto savedSites = std::move(returnSites);
  returnSites.clear();
  if (resultSlot)
    resultPtr = resultSlot;

  SmallVector<Operation *> scratch;
  auto cleanup = [&]() {
    // Later clones use earlier clone results, so drop them in reverse order.
    for (auto it = scratch.rbegin(); it != scratch.rend(); ++it)
      (*it)->destroy();
    scratch.clear();
  };

  for (Operation &inner : body.getOperations()) {
    StringRef name = inner.getName().getStringRef();
    if (name == "hlcf.return") {
      if (inner.getNumOperands() == 1) {
        auto mapped = subst.find(inner.getOperand(0));
        if (mapped != subst.end()) {
          if (LogicValue logic = getLogicValue(mapped->second); logic)
            returnSites.push_back({condition, logic.val, logic.xz});
          else if (Value value = getValue(mapped->second))
            returnSites.push_back({condition, value, Value()});
        }
      }
      break;
    }
    if (name == "pop.stack_allocation") {
      subst[inner.getResult(0)] = inner.getResult(0);
      continue;
    }
    if (name.starts_with("pop.stack_alloc.lifetime") ||
        name.starts_with("debuginfo."))
      continue;
    if (name == "kgen.struct.gep") {
      if (inner.getNumOperands() != 1) {
        inner.emitError()
            << "HDL lowering: unsupported struct method field access";
        cleanup();
        return failure();
      }
      auto index = inner.getAttrOfType<IntegerAttr>("index");
      if (!index) {
        inner.emitError()
            << "HDL lowering: unsupported struct method field access";
        cleanup();
        return failure();
      }
      auto base = subst.find(inner.getOperand(0));
      if (base == subst.end()) {
        inner.emitError()
            << "HDL lowering: struct method field base was not lowered";
        cleanup();
        return failure();
      }
      auto path = resolveStructFieldPath(base->second, index.getInt());
      if (!path) {
        inner.emitError()
            << "HDL lowering: struct method field base is not a struct";
        cleanup();
        return failure();
      }
      structFieldPaths[inner.getResult(0)] = *path;
      Value slot = getStructFieldSlot(&inner, path->root, path->path);
      subst[inner.getResult(0)] = slot;
      continue;
    }

    Operation *cloned = inner.clone();
    scratch.push_back(cloned);
    // Substitute operands throughout the cloned body, including nested
    // regions (for example an `hlcf.if` inside the method). Values defined
    // inside the clone stay bound to their cloned definitions.
    bool substituted = true;
    cloned->walk([&](Operation *nested) {
      if (!substituted)
        return;
      for (unsigned i = 0; i < nested->getNumOperands(); ++i) {
        Value operand = nested->getOperand(i);
        if (Operation *defining = operand.getDefiningOp()) {
          if (defining == cloned || cloned->isProperAncestor(defining))
            continue;
        } else if (auto argument = dyn_cast<BlockArgument>(operand)) {
          Operation *parent = argument.getOwner()->getParentOp();
          if (parent == cloned ||
              (parent && cloned->isProperAncestor(parent)))
            continue;
        }
        auto value = subst.find(operand);
        if (value == subst.end()) {
          substituted = false;
          return;
        }
        nested->setOperand(i, value->second);
      }
    });
    if (!substituted) {
      inner.emitError()
          << "HDL lowering: struct method operand was not lowered";
      cleanup();
      return failure();
    }
    if (failed(emitOp(cloned, condition, returnValue))) {
      cleanup();
      return failure();
    }
    for (unsigned i = 0; i < cloned->getNumResults(); ++i)
      subst[inner.getResult(i)] = cloned->getResult(i);
  }
  if (resultSlot && !returnSites.empty()) {
    Value result = returnSites.back().value;
    Value resultXz = returnSites.back().xz;
    for (size_t i = returnSites.size() - 1; i-- > 0;) {
      ReturnSite &site = returnSites[i];
      if (site.condition) {
        result = comb::MuxOp::create(builder, loc, site.condition, site.value,
                                     result);
        if (resultXz)
          resultXz = comb::MuxOp::create(builder, loc, site.condition, site.xz,
                                         resultXz);
      } else {
        result = site.value;
        resultXz = site.xz;
      }
    }
    if (resultXz) {
      logicValues[resultSlot] = {result, resultXz};
      values[resultSlot] = result;
    } else {
      values[resultSlot] = result;
    }
  }
  resultPtr = savedResultPtr;
  returnValue = savedReturnValue;
  returnIsLogic = savedReturnIsLogic;
  returnXz = savedReturnXz;
  returnSites = std::move(savedSites);
  cleanup();
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
    DenseMap<Value, llvm::APInt> packedConstants;
    DenseMap<Value, Value> storeSources;
    auto resolveConstant = [&](Value value) -> std::optional<llvm::APInt> {
      if (auto constant = constants.find(value); constant != constants.end())
        return constant->second;
      Operation *defining = value.getDefiningOp();
      if (!defining)
        return std::nullopt;
      if (defining->getName().getStringRef() == "kgen.call" &&
          callCalleeName(defining).contains("Packed::__init__")) {
        Value argument = defining->getOperand(0);
        if (auto constant = constants.find(argument);
            constant != constants.end())
          return constant->second;
        if (Operation *argDef = argument.getDefiningOp())
          return getConstantInt(argDef, &bindings);
        return std::nullopt;
      }
      return getConstantInt(defining, &bindings);
    };
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
        storeSources[op.getOperand(1)] = op.getOperand(0);
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
      // `Ram` and `ArrayRam` forward their constructors to an inner `Mem`, but
      // the module-level `__init__` only shows the outer call.
      auto isMemoryInit = [](StringRef name) {
        return (name.contains("Mem::__init__") ||
                name.contains("Ram::__init__") ||
                name.contains("ArrayRam::__init__")) &&
               !name.contains("__init__(move:");
      };
      if (!callee.contains("Bits::__init__") &&
          !callee.contains("Logic::__init__") &&
          !callee.contains("Reg::__init__") &&
          !callee.contains("Packed::__init__") &&
          !callee.contains("Array::__init__") && !isMemoryInit(callee))
        continue;
      // A packed constructor writes its integer constant through a
      // destination pointer; remember it so a following `Reg[Packed]`
      // constructor can resolve its reset value.
      if (callee.contains("Packed::__init__") &&
          !callee.contains("__init__(move:")) {
        Value dest = op.getOperand(op.getNumOperands() - 1);
        if (auto value = resolveConstant(op.getOperand(0)))
          packedConstants[dest] = *value;
        continue;
      }

      // A payload `Array[T, N](constant)` initializes a field directly.
      // Storage arrays (`Array[Reg[T], N]`) keep their per-entry path.
      if (callee.contains("Array::__init__") &&
          !callee.contains("__init__(move:") && op.getNumOperands() == 2) {
        auto field = fieldIndexes.find(op.getOperand(1));
        if (field != fieldIndexes.end() &&
            !(field->second < fieldIsArrayStorage.size() &&
              fieldIsArrayStorage[field->second])) {
          if (auto value = resolveConstant(op.getOperand(0)))
            resetValues[field->second] = *value;
        }
        continue;
      }

      // A memory constructor can carry one constant per entry. The variadic
      // form builds a VariadicList over a `pop.array.create` whose elements
      // are pointers to stored constants.
      if (isMemoryInit(callee)) {
        Value dest = op.getOperand(op.getNumOperands() - 1);
        auto field = fieldIndexes.find(dest);
        if (field == fieldIndexes.end())
          continue;
        SmallVector<llvm::APInt> values;
        if (op.getNumOperands() == 2) {
          auto listStored = storeSources.find(op.getOperand(0));
          if (listStored != storeSources.end()) {
            Operation *listOp = listStored->second.getDefiningOp();
            if (listOp && listOp->getName().getStringRef() == "kgen.call" &&
                listOp->getNumOperands() == 1) {
              auto arrayStored = storeSources.find(listOp->getOperand(0));
              if (arrayStored != storeSources.end()) {
                Operation *arrayOp = arrayStored->second.getDefiningOp();
                if (arrayOp &&
                    arrayOp->getName().getStringRef() == "pop.array.create") {
                  bool allConstants = true;
                  for (Value elementPtr : arrayOp->getOperands()) {
                    auto elementStored = storeSources.find(elementPtr);
                    Operation *valueOp =
                        elementStored == storeSources.end()
                            ? nullptr
                            : elementStored->second.getDefiningOp();
                    auto value = valueOp
                                     ? getConstantInt(valueOp, &bindings)
                                     : std::nullopt;
                    if (!value) {
                      allConstants = false;
                      break;
                    }
                    values.push_back(*value);
                  }
                  if (!allConstants)
                    values.clear();
                }
              }
            }
          }
        } else {
          bool allConstants = true;
          for (unsigned i = 0; i + 1 < op.getNumOperands(); ++i) {
            Operation *valueOp = op.getOperand(i).getDefiningOp();
            auto value =
                valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
            if (!value) {
              allConstants = false;
              break;
            }
            values.push_back(*value);
          }
          if (!allConstants)
            values.clear();
        }
        if (!values.empty()) {
          arrayResetSequences[field->second] = values;
          continue;
        }
        // A single-value fill falls through to the generic constant path.
      }

      // A direct `Bits[W](constant)` assignment can initialize the field
      // through the field pointer without a temporary.
      if (op.getNumOperands() == 2 && !callee.contains("__init__(move:")) {
        auto field = fieldIndexes.find(op.getOperand(1));
        if (field == fieldIndexes.end())
          continue;
        std::optional<llvm::APInt> result;
        if (auto packed = packedConstants.find(op.getOperand(0));
            packed != packedConstants.end())
          result = packed->second;
        else
          result = resolveConstant(op.getOperand(0));
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

/// Recognize array-storage fields: `Mem[T, N]` and `Array[Reg[T], N]`.
/// Returns the payload type and depth. A plain `Array[T, N]` of payloads is a
/// packed value (use `Packed`), not storage.
static bool getArrayStorageInfo(Type type, const ParamBindings *bindings,
                                Type &payload, unsigned &depth) {
  StringRef name = getDslTypeName(type);
  if (name.empty())
    return false;
  Type first = getDslTypeParam(type, 0);
  auto depthValue = getDslTypeIntParam(type, 1, bindings);
  if (!first || !depthValue)
    return false;
  if (name.ends_with("Mem")) {
    payload = first;
    depth = depthValue->getZExtValue();
    return true;
  }
  if (name.ends_with("Array")) {
    if (!getDslTypeName(first).contains("Reg"))
      return false;
    payload = getDslTypeParam(first, 0);
    if (!payload)
      return false;
    depth = depthValue->getZExtValue();
    return true;
  }
  return false;
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
    bool isClockDivider = StringRef(typeName).contains("ClockDivider");
    bool isConfig = StringRef(typeName).contains("ResetStyle") ||
                    isPowerOn || isClockDivider;
    Type arrayPayload;
    unsigned arrayDepth = 0;
    bool isArrayRam = !isConfig && StringRef(typeName).ends_with("ArrayRam");
    bool isRam = !isConfig && !isArrayRam &&
                 StringRef(typeName).ends_with("Ram");
    bool isArrayStorage = isRam || isArrayRam;
    if (isRam || isArrayRam) {
      arrayPayload = getDslTypeParam(fieldType, 0);
      if (auto depth = getDslTypeIntParam(fieldType, 1, &bindings))
        arrayDepth = depth->getZExtValue();
    } else if (!isConfig) {
      isArrayStorage = getArrayStorageInfo(fieldType, &bindings, arrayPayload,
                                           arrayDepth);
    }
    bool isWire = !isConfig && !isArrayStorage &&
                  StringRef(typeName).ends_with("Wire");
    bool isReg = !isConfig && !isArrayStorage && !isWire &&
                 StringRef(typeName).ends_with("Reg");
    fieldIsConfig.push_back(isConfig);
    fieldIsArrayStorage.push_back(isArrayStorage);
    fieldIsWire.push_back(isWire);
    fieldArrayWidths.push_back(0);
    fieldArrayDepths.push_back(0);
    fieldResetStyle.push_back(resetStyle);
    if (isConfig) {
      if (auto value = getDslTypeBinding(fieldType, &bindings)) {
        if (isPowerOn)
          powerOnValue = *value;
        else if (isClockDivider)
          clockDivisor = static_cast<int>(value->getZExtValue());
        else
          resetStyle = static_cast<int>(value->getZExtValue());
      }
      fieldWidths.push_back(0);
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(false);
      fieldModuleNames.push_back({});
      continue;
    }

    if (isReg) {
      Type element = getDslTypeParam(fieldType, 0);
      fieldWidths.push_back(element ? getHdlWidth(element, &bindings) : 0);
      if (auto style = getDslTypeIntParam(fieldType, 1, &bindings))
        fieldResetStyle.back() = style->getZExtValue();
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(element && isLogicType(element));
      fieldModuleNames.push_back({});
      continue;
    }

    if (isWire) {
      auto params = getDslTypeBindings(fieldType, &bindings);
      fieldWidths.push_back(params.empty() ? 0 : params[0].getZExtValue());
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(false);
      fieldModuleNames.push_back({});
      continue;
    }

    if (isArrayStorage) {
      fieldArrayWidths.back() = getHdlWidth(arrayPayload, &bindings);
      fieldArrayDepths.back() = arrayDepth;
      fieldWidths.push_back(0);
      fieldIsInstance.push_back(false);
      fieldIsLogic.push_back(false);
      fieldModuleNames.push_back({});
      arrayIsLogic[fieldIsArrayStorage.size() - 1] =
          arrayPayload && isLogicType(arrayPayload);
      arrayIsExplicitRam[fieldIsArrayStorage.size() - 1] = isRam;
      arrayIsArrayRam[fieldIsArrayStorage.size() - 1] = isArrayRam;
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
    fieldIsLogic.push_back(isLogicType(fieldType));
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

LogicalResult CirctModuleEmitter::collectProcesses(
    SmallVectorImpl<std::string> &processes) {
  if (failed(findMethods()))
    return failure();
  for (unsigned m = 0; m < methods.size(); ++m) {
    Operation *fn = methods[m];
    KGEN::FuncType sourceFunc = getSourceFuncType(fn);
    if (!sourceFunc)
      continue;
    ArrayRef<KGEN::ArgConvention> conventions =
        sourceFunc.getArgConventions();
    if (conventions.size() != 1 || conventions[0] != KGEN::ArgConvention::Mut)
      continue;
    auto funcType = getFuncTypeGenerator(fn);
    if (!funcType)
      continue;
    auto results = funcType.getBody().getResults();
    if (results.size() > 1)
      continue;
    if (results.size() == 1 && !isa<KGEN::NoneType>(results[0]))
      continue;
    processes.push_back(methodNames[m]);
  }
  return success();
}

SmallVector<Value>
CirctModuleEmitter::collectLoopCarriedSlots(Block &block,
                                            Value inductionSlot) {
  SmallVector<Value> result;
  auto add = [&](Value value) {
    if (!value || value == inductionSlot || fieldPtrs.count(value))
      return;
    if (!llvm::is_contained(stackSlots, value))
      return;
    if (!llvm::is_contained(result, value))
      result.push_back(value);
  };
  auto addPointer = [&](Value value, Value calleeSelf = Value(),
                        Value callerSelf = Value()) {
    if (Operation *defining = value.getDefiningOp();
        defining && defining->getName().getStringRef() == "kgen.struct.gep" &&
        defining->getNumOperands() == 1) {
      Value base = defining->getOperand(0);
      if (calleeSelf && base == calleeSelf)
        base = callerSelf;
      if (auto index = defining->getAttrOfType<IntegerAttr>("index"))
        if (auto path = resolveStructFieldPath(base, index.getInt())) {
          structFieldPaths[defining->getResult(0)] = *path;
          Value slot =
              getStructFieldSlot(defining, path->root, path->path);
          structFieldAliases[value] = slot;
          add(slot);
          return;
        }
    }
    add(value);
  };
  auto scan = [&](Operation *op) {
    StringRef name = op->getName().getStringRef();
    if (name == "pop.store" && op->getNumOperands() == 2) {
      addPointer(op->getOperand(1));
      return;
    }
    if (name != "kgen.call")
      return;
    StringRef callee = callCalleeName(op);
    if ((callee.contains("Bits::copy") || callee.contains("Bits::__init__") ||
         callee.contains("Logic::copy") || callee.contains("Logic::__init__") ||
         callee.contains("Array::copy") || callee.contains("Array::__init__") ||
         callee.contains("Packed::copy") ||
         callee.contains("Packed::__init__")) &&
        op->getNumOperands() >= 2)
      addPointer(op->getOperand(op->getNumOperands() - 1));
    else if ((callee.contains("Array::__setitem__") ||
              callee.contains("Packed::__setitem__")) &&
             op->getNumOperands() >= 1)
      add(op->getOperand(0));
    else if (callee.contains("SIMD::__iadd__") && op->getNumOperands() == 2)
      add(op->getOperand(0));
    else if (op->getNumOperands() >= 1 &&
             llvm::is_contained(stackSlots, op->getOperand(0)) &&
             !callee.split('(').first.contains("hdl::") &&
             !callee.split('(').first.contains("std::") &&
             !callee.split('(').first.ends_with("::__init__") &&
             !callee.split('(').first.ends_with("::__copyinit__") &&
             !callee.split('(').first.ends_with("::__moveinit__")) {
      // A simple user struct method: scan its field stores so the fields it
      // updates become carried slots of the caller's loop.
      Operation *method = findFunction(callee);
      auto func = method ? dyn_cast<FunctionOpInterface>(method) : nullptr;
      if (!func || func.getFunctionBody().empty())
        return;
      Block &methodBody = func.getFunctionBody().front();
      if (methodBody.getNumArguments() == 0)
        return;
      Value calleeSelf = methodBody.getArgument(0);
      Value callerSelf = op->getOperand(0);
      methodBody.walk([&](Operation *inner) {
        StringRef innerName = inner->getName().getStringRef();
        if (innerName == "kgen.struct.gep" && inner->getNumOperands() == 1) {
          Value base = inner->getOperand(0);
          if (base == calleeSelf)
            base = callerSelf;
          if (auto index = inner->getAttrOfType<IntegerAttr>("index"))
            if (auto path = resolveStructFieldPath(base, index.getInt()))
              structFieldPaths[inner->getResult(0)] = *path;
          return;
        }
        if (innerName == "pop.store" && inner->getNumOperands() == 2) {
          addPointer(inner->getOperand(1), calleeSelf, callerSelf);
          return;
        }
        if (innerName != "kgen.call" || inner->getNumOperands() < 2)
          return;
        StringRef innerCallee = callCalleeName(inner);
        if ((innerCallee.contains("Bits::copy") ||
             innerCallee.contains("Bits::__init__") ||
             innerCallee.contains("Logic::copy") ||
             innerCallee.contains("Logic::__init__") ||
             innerCallee.contains("Array::copy") ||
             innerCallee.contains("Array::__init__") ||
             innerCallee.contains("Packed::copy") ||
             innerCallee.contains("Packed::__init__")))
          addPointer(inner->getOperand(inner->getNumOperands() - 1),
                     calleeSelf, callerSelf);
      });
    }
  };
  // Register every GEP chain first, so a nested field store can resolve its
  // full path during the store scan.
  auto registerPath = [&](Operation *op) {
    if (op->getName().getStringRef() != "kgen.struct.gep" ||
        op->getNumOperands() != 1)
      return;
    auto index = op->getAttrOfType<IntegerAttr>("index");
    if (!index)
      return;
    if (auto path = resolveStructFieldPath(op->getOperand(0),
                                           index.getInt()))
      structFieldPaths[op->getResult(0)] = *path;
  };
  for (Operation &op : block.getOperations())
    op.walk(registerPath);
  for (Operation &op : block.getOperations())
    op.walk(scan);
  return result;
}

bool CirctModuleEmitter::storeLoopCarriedLogic(Value slot, LogicValue value,
                                               Value condition) {
  auto next = loopCarriedLogicNext.find(slot);
  if (next == loopCarriedLogicNext.end())
    return false;
  if (condition) {
    next->second.val = comb::MuxOp::create(builder, loc, condition, value.val,
                                           next->second.val);
    next->second.xz = comb::MuxOp::create(builder, loc, condition, value.xz,
                                          next->second.xz);
  } else {
    next->second = value;
  }
  // Subsequent reads in this iteration see the composed update.
  values[slot] = next->second.val;
  logicValues[slot] = next->second;
  return true;
}

bool CirctModuleEmitter::storeLoopCarried(Value slot, Value value,
                                          Value condition) {
  auto next = loopCarriedNext.find(slot);
  if (next == loopCarriedNext.end())
    return false;
  next->second = condition
                     ? comb::MuxOp::create(builder, loc, condition, value,
                                           next->second)
                     : value;
  // Subsequent reads in this iteration see the composed update.
  values[slot] = next->second;
  return true;
}

bool CirctModuleEmitter::isLoopCarriedSlot(Value value) const {
  if (!inDynamicLoop || value == dynamicLoopSlot)
    return false;
  return llvm::is_contained(dynamicLoopOuterSlots, value);
}

Value CirctModuleEmitter::resolveStructField(Value value) const {
  auto it = structFieldAliases.find(value);
  return it != structFieldAliases.end() ? it->second : value;
}

std::optional<CirctModuleEmitter::StructFieldPath>
CirctModuleEmitter::resolveStructFieldPath(Value base, unsigned index) const {
  auto known = structFieldPaths.find(base);
  if (known != structFieldPaths.end()) {
    StructFieldPath result = known->second;
    result.path.push_back(index);
    return result;
  }
  if (base != selfPtr && llvm::is_contained(stackSlots, base)) {
    StructFieldPath result;
    result.root = base;
    result.path.push_back(index);
    return result;
  }
  return std::nullopt;
}

Value CirctModuleEmitter::getStructFieldSlot(Operation *gep, Value root,
                                             ArrayRef<unsigned> path) {
  auto &fields = structFieldSlots[root];
  for (auto &[candidate, slot] : fields)
    if (candidate == path)
      return slot;
  // The GEP pointer is only a map key: it is never emitted, so it is safe to
  // reuse a source-region value as the canonical slot.
  Value slot = gep->getResult(0);
  fields.push_back({SmallVector<unsigned>(path), slot});
  stackSlots.push_back(slot);
  if (path.size() == 1) {
    if (auto inits = structFieldInits.find(root);
        inits != structFieldInits.end())
      for (auto &[initIndex, init] : inits->second)
        if (initIndex == path[0]) {
          values[slot] = init.val;
          if (init.xz)
            logicValues[slot] = {init.val, init.xz};
          break;
        }
  }
  return slot;
}

LogicalResult CirctModuleEmitter::emitStructConstructor(Operation *op,
                                                        StringRef callee,
                                                        Value condition,
                                                        Value &returnValue) {
  Operation *calleeOp = nullptr;
  for (Operation &candidate : source.getBody()->getOperations()) {
    auto symbol =
        candidate.getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
    if (symbol && symbol.getValue() == callee) {
      calleeOp = &candidate;
      break;
    }
  }
  if (!calleeOp)
    return op->emitError()
           << "HDL lowering: struct constructor '" << callee
           << "' was not found";
  auto func = dyn_cast<FunctionOpInterface>(calleeOp);
  if (!func || func.getFunctionBody().empty())
    return op->emitError()
           << "HDL lowering: struct constructor has no body";
  Block &body = func.getFunctionBody().front();
  if (body.getNumArguments() < 1)
    return op->emitError()
           << "HDL lowering: struct constructor has no self argument";
  Value self;
  DenseMap<Value, unsigned> fieldOf;
  for (Operation &o : body.getOperations()) {
    if (o.getName().getStringRef() != "kgen.struct.gep" ||
        o.getNumOperands() != 1)
      continue;
    Value base = o.getOperand(0);
    bool isArgument = false;
    for (BlockArgument argument : body.getArguments())
      if (argument == base)
        isArgument = true;
    if (!isArgument)
      continue;
    auto index = o.getAttrOfType<IntegerAttr>("index");
    if (!index)
      continue;
    self = base;
    fieldOf[o.getResult(0)] = index.getInt();
  }
  if (!self)
    return op->emitError()
           << "HDL lowering: struct constructor has no field stores";
  Value dest = op->getOperand(op->getNumOperands() - 1);
  // A constructor writing into a nested struct field is inlined so its leaf
  // fields get values directly instead of a lazy init on the root slot.
  if (structFieldPaths.count(dest))
    return emitStructMethod(op, callee, condition, returnValue);
  struct CtorInit {
    unsigned field;
    Value source;
    unsigned width;
  };
  SmallVector<CtorInit> inits;
  bool forceInline = false;
  auto isPayloadCopy = [](StringRef name) {
    return name.contains("Bits::copy") || name.contains("Bits::__init__") ||
           name.contains("Logic::copy") || name.contains("Logic::__init__") ||
           name.contains("Array::copy") || name.contains("Array::__init__") ||
           name.contains("Packed::copy") || name.contains("Packed::__init__");
  };
  for (Operation &o : body.getOperations()) {
    StringRef name = o.getName().getStringRef();
    if (name == "pop.store" && o.getNumOperands() == 2) {
      auto field = fieldOf.find(o.getOperand(1));
      if (field != fieldOf.end())
        inits.push_back({field->second, o.getOperand(0), 0});
      else if (Operation *target = o.getOperand(1).getDefiningOp();
               target &&
               target->getName().getStringRef() == "kgen.struct.gep")
        forceInline = true;
      continue;
    }
    if (name != "kgen.call" || o.getNumOperands() < 2)
      continue;
    StringRef inner = callCalleeName(&o);
    if (!isPayloadCopy(inner)) {
      StringRef innerName = inner.split('(').first;
      if (innerName.ends_with("::__init__") ||
          innerName.ends_with("::__copyinit__") ||
          innerName.ends_with("::__moveinit__"))
        forceInline = true;
      continue;
    }
    auto field = fieldOf.find(o.getOperand(o.getNumOperands() - 1));
    if (field == fieldOf.end()) {
      if (Operation *target =
              o.getOperand(o.getNumOperands() - 1).getDefiningOp();
          target && target->getName().getStringRef() == "kgen.struct.gep")
        forceInline = true;
      continue;
    }
    unsigned width = 0;
    if (inner.contains("Bits::__init__") || inner.contains("Logic::__init__"))
      width = getCallParamWidth(&o, &bindings);
    inits.push_back({field->second, o.getOperand(0), width});
  }
  // A constructor that computes field values is inlined like a method. The
  // simple path only records direct argument/constant copies, which the
  // caller applies lazily when each field slot is first needed.
  auto isSimpleInitializer = [&](Value source) {
    for (BlockArgument argument : body.getArguments())
      if (source == argument)
        return true;
    if (Operation *defining = source.getDefiningOp())
      if (getConstantInt(defining, &bindings))
        return true;
    return false;
  };
  bool computed = inits.empty() || forceInline;
  for (auto &[field, source, width] : inits)
    if (!isSimpleInitializer(source))
      computed = true;
  if (computed)
    return emitStructMethod(op, callee, condition, returnValue);
  for (auto &[field, source, width] : inits) {
    Value value;
    Value xz;
    unsigned argumentIndex = ~0u;
    for (unsigned i = 0; i < body.getNumArguments(); ++i)
      if (source == body.getArgument(i)) {
        argumentIndex = i;
        break;
      }
    if (argumentIndex != ~0u) {
      if (argumentIndex >= op->getNumOperands() - 1)
        return op->emitError()
               << "HDL lowering: struct constructor argument was not "
                  "lowered";
      Value argument = op->getOperand(argumentIndex);
      if (auto logic = getLogicValue(argument)) {
        value = logic.val;
        xz = logic.xz;
      } else {
        value = getValue(argument);
      }
    } else if (Operation *defining = source.getDefiningOp()) {
      if (auto constant = getConstantInt(defining, &bindings)) {
        llvm::APInt bits = *constant;
        if (width && bits.getBitWidth() != width)
          bits = bits.zextOrTrunc(width);
        value = hw::ConstantOp::create(builder, loc, bits);
      }
    }
    if (!value)
      return op->emitError()
             << "HDL lowering: struct constructor field value was not "
                "lowered";
    structFieldInits[dest].push_back(
        {field, StructFieldInit{value, xz}});
  }
  return success();
}

std::string CirctModuleEmitter::domainName(unsigned method) const {
  if (method < methodHasState.size() && !methodHasState[method])
    return "combinational";
  if (methods.size() == 1)
    return "clk";
  if (method < methodNames.size())
    return "clk_" + methodNames[method];
  return "unknown";
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

static void setHoldValue(Value reg);

SmallVector<Value> &
CirctModuleEmitter::getOrCreateArrayStorage(unsigned fieldIndex) {
  auto found = arrayRegs.find(fieldIndex);
  if (found != arrayRegs.end())
    return found->second;
  auto &regs = arrayRegs[fieldIndex];
  unsigned width = fieldArrayWidths[fieldIndex];
  unsigned depth = fieldArrayDepths[fieldIndex];
  bool isLogic = arrayIsLogic.lookup(fieldIndex);
  auto type = IntegerType::get(builder.getContext(), width);
  auto zero = hw::ConstantOp::create(builder, loc, type, 0);
  auto ceZero =
      hw::ConstantOp::create(builder, loc, builder.getIntegerType(1), 0);
  Value reset = (resetStyle & 1) ? bitNot(resetSignal) : resetSignal;
  bool async = resetStyle >= 2;
  auto sequence = arrayResetSequences.find(fieldIndex);
  for (unsigned k = 0; k < depth; ++k) {
    llvm::APInt resetBits(width, 0);
    if (sequence != arrayResetSequences.end() &&
        k < sequence->second.size())
      resetBits = sequence->second[k].zextOrTrunc(width);
    else if (auto value = resetValues.find(fieldIndex);
             value != resetValues.end())
      resetBits = value->second.zextOrTrunc(width);
    llvm::APInt initialBits = resetBits;
    if (powerOnValue)
      initialBits = powerOnValue->zextOrTrunc(width);

    auto resetValue = hw::ConstantOp::create(builder, loc, resetBits);
    auto name = StringAttr::get(
        builder.getContext(),
        "mem_" + std::to_string(fieldIndex) + "_" + std::to_string(k));
    if (async) {
      regs.push_back(seq::FirRegOp::create(
          builder, loc, zero, clk, name, reset, resetValue,
          hw::InnerSymAttr(), /*isAsync=*/true,
          /*preset=*/IntegerAttr::get(type, initialBits)));
    } else {
      auto initial = seq::createConstantInitialValue(
          builder, loc, IntegerAttr::get(type, initialBits));
      regs.push_back(seq::CompRegClockEnabledOp::create(
          builder, loc, zero, clk, ceZero, reset, resetValue, name, initial));
    }

    if (isLogic) {
      auto &xzRegs = arrayXzRegs[fieldIndex];
      auto xzName = StringAttr::get(
          builder.getContext(), "mem_" + std::to_string(fieldIndex) + "_" +
                                    std::to_string(k) + "_xz");
      auto xzZero = hw::ConstantOp::create(builder, loc,
                                           llvm::APInt(width, 0));
      if (async) {
        xzRegs.push_back(seq::FirRegOp::create(
            builder, loc, zero, clk, xzName, reset, xzZero,
            hw::InnerSymAttr(), /*isAsync=*/true,
            /*preset=*/IntegerAttr::get(type, llvm::APInt(width, 0))));
      } else {
        auto xzInitial = seq::createConstantInitialValue(
            builder, loc, IntegerAttr::get(type, llvm::APInt(width, 0)));
        xzRegs.push_back(seq::CompRegClockEnabledOp::create(
            builder, loc, zero, clk, ceZero, reset, xzZero, xzName,
            xzInitial));
      }
    }
  }
  for (Value reg : regs)
    setHoldValue(reg);
  if (isLogic)
    for (Value reg : arrayXzRegs[fieldIndex])
      setHoldValue(reg);
  arrayNext[fieldIndex] = regs;
  if (isLogic)
    arrayXzNext[fieldIndex] = arrayXzRegs[fieldIndex];
  arrayEnable[fieldIndex] = SmallVector<Value>(depth, ceZero);
  arrayWritten[fieldIndex] = SmallVector<bool>(depth, false);
  return regs;
}

bool CirctModuleEmitter::collectMemoryInit(
    unsigned fieldIndex, unsigned width, unsigned depth,
    SmallVectorImpl<llvm::APInt> &reset,
    SmallVectorImpl<llvm::APInt> &poweron) {
  reset.assign(depth, llvm::APInt(width, 0));
  auto sequence = arrayResetSequences.find(fieldIndex);
  auto fill = resetValues.find(fieldIndex);
  for (unsigned k = 0; k < depth; ++k) {
    if (sequence != arrayResetSequences.end() && k < sequence->second.size())
      reset[k] = sequence->second[k].zextOrTrunc(width);
    else if (fill != resetValues.end())
      reset[k] = fill->second.zextOrTrunc(width);
  }
  poweron.assign(reset.begin(), reset.end());
  bool nonzero = false;
  if (powerOnValue) {
    for (unsigned k = 0; k < depth; ++k)
      poweron[k] = powerOnValue->zextOrTrunc(width);
    nonzero = !powerOnValue->isZero();
  }
  for (const llvm::APInt &value : reset)
    nonzero |= !value.isZero();
  return nonzero;
}

Value CirctModuleEmitter::getOrCreateHLMem(unsigned fieldIndex) {
  auto found = hlMemOps.find(fieldIndex);
  if (found != hlMemOps.end())
    return found->second;
  unsigned width = fieldArrayWidths[fieldIndex];
  unsigned depth = fieldArrayDepths[fieldIndex];
  auto elementType = IntegerType::get(builder.getContext(), width);
  auto name = "ram_" + std::to_string(fieldIndex);
  Value reset = (resetStyle & 1) ? bitNot(resetSignal) : resetSignal;
  auto memOp = seq::HLMemOp::create(
      builder, loc, clk, reset, name,
      llvm::SmallVector<int64_t>{static_cast<int64_t>(depth)}, elementType);
  SmallVector<llvm::APInt> resetBits, powerOnBits;
  if (collectMemoryInit(fieldIndex, width, depth, resetBits, powerOnBits)) {
    auto toAttr = [&](ArrayRef<llvm::APInt> values) {
      SmallVector<Attribute> attrs;
      for (const llvm::APInt &value : values)
        attrs.push_back(IntegerAttr::get(elementType, value));
      return ArrayAttr::get(builder.getContext(), attrs);
    };
    memOp->setAttr("hdl.reset", toAttr(resetBits));
    memOp->setAttr("hdl.poweron", toAttr(powerOnBits));
    if (resetStyle >= 2)
      memOp->setAttr("hdl.reset_async",
                     UnitAttr::get(builder.getContext()));
  }
  hlMemOps[fieldIndex] = memOp.getHandle();
  return memOp.getHandle();
}

Value CirctModuleEmitter::getOrCreateArrayRam(unsigned fieldIndex) {
  auto found = arrayRamRegs.find(fieldIndex);
  if (found != arrayRamRegs.end())
    return found->second;
  unsigned width = fieldArrayWidths[fieldIndex];
  unsigned depth = fieldArrayDepths[fieldIndex];
  auto type = IntegerType::get(builder.getContext(), width);
  SmallVector<Value> zeros;
  for (unsigned k = 0; k < depth; ++k)
    zeros.push_back(hw::ConstantOp::create(builder, loc, type, 0));
  auto arrayType = hw::ArrayType::get(type, depth);
  ValueRange zeroInputs(zeros);
  auto zeroArrayOp = hw::ArrayCreateOp::create(builder, loc, zeroInputs);
  Value zeroArray = zeroArrayOp.getResult();
  auto name = StringAttr::get(
      builder.getContext(), "array_ram_" + std::to_string(fieldIndex));

  SmallVector<llvm::APInt> resetBits, powerOnBits;
  bool initialized =
      collectMemoryInit(fieldIndex, width, depth, resetBits, powerOnBits);
  seq::FirRegOp reg;
  if (initialized) {
    SmallVector<Value> resetElements;
    for (unsigned k = 0; k < depth; ++k)
      resetElements.push_back(
          hw::ConstantOp::create(builder, loc, resetBits[k]));
    ValueRange resetInputs(resetElements);
    Value resetArray =
        hw::ArrayCreateOp::create(builder, loc, resetInputs).getResult();
    llvm::APInt preset(depth * width, 0);
    for (unsigned k = 0; k < depth; ++k)
      preset.insertBits(powerOnBits[k], k * width);
    auto presetAttr = IntegerAttr::get(
        IntegerType::get(builder.getContext(), depth * width), preset);
    Value reset = (resetStyle & 1) ? bitNot(resetSignal) : resetSignal;
    reg = seq::FirRegOp::create(builder, loc, zeroArray, clk, name, reset,
                                resetArray, hw::InnerSymAttr(),
                                /*isAsync=*/resetStyle >= 2, presetAttr);
  } else {
    reg = seq::FirRegOp::create(builder, loc, zeroArray, clk, name,
                                hw::InnerSymAttr(), Attribute{});
  }
  Value value = reg.getResult();
  reg->setOperand(0, value);
  arrayRamRegs[fieldIndex] = value;
  return value;
}

Operation *CirctModuleEmitter::findBuiltModule(StringRef name) {
  StringRef displayName = name.contains("::") ? name.rsplit("::").second : name;
  for (Operation &op : scratch.getBody()->getOperations())
    if (auto module = dyn_cast<hw::HWModuleOp>(&op))
      if (module.getModuleName() == displayName)
        return module;
  return nullptr;
}

std::optional<llvm::APInt>
CirctModuleEmitter::resolveConstant(Value value) {
  if (auto constant = intConstants.find(value); constant != intConstants.end())
    return constant->second;
  if (auto constant = slotConstants.find(value);
      constant != slotConstants.end())
    return constant->second;
  if (auto constant = value.getDefiningOp<hw::ConstantOp>())
    return constant.getValue();
  if (auto materialized = values.find(value); materialized != values.end())
    if (auto constant = materialized->second.getDefiningOp<hw::ConstantOp>())
      return constant.getValue();
  return std::nullopt;
}

std::optional<CirctModuleEmitter::RangeValue>
CirctModuleEmitter::resolveRange(Value value) {
  if (auto range = rangeValues.find(value); range != rangeValues.end())
    return range->second;
  return std::nullopt;
}

Value CirctModuleEmitter::getValue(Value value) {
  value = resolveStructField(value);
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
    if (index < fieldIsArrayStorage.size() && fieldIsArrayStorage[index])
      return {};
    if (index < fieldIsWire.size() && fieldIsWire[index])
      return wireValues.lookup(index);
    fieldReaders[index].insert(currentMethod);
    auto type = IntegerType::get(value.getContext(), fieldWidths[index]);
    return getOrCreateReg(index, type);
  }
  return {};
}

CirctModuleEmitter::LogicValue CirctModuleEmitter::getLogicValue(Value value) {
  value = resolveStructField(value);
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
  if (auto delayed = delayedLogicNextRegs.find(fieldIndex);
      delayed != delayedLogicNextRegs.end() && !delayed->second.empty())
    return delayed->second.back();
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
  setHoldValue(valReg);
  setHoldValue(xzReg);
  LogicValue regs{valReg, xzReg};
  logicRegs[fieldIndex] = regs;
  logicNext[fieldIndex] = regs;
  return regs;
}

LogicalResult CirctModuleEmitter::storeLogicField(unsigned fieldIndex,
                                                 LogicValue value,
                                                 Value condition) {
  if (delayedLogicNextRegs.count(fieldIndex))
    return source.emitError()
           << "HDL lowering: cannot mix immediate and delayed next on Logic "
              "field '"
           << fieldNames[fieldIndex] << "'";
  if (auto writer = fieldWriter.find(fieldIndex);
      writer != fieldWriter.end() && writer->second != currentMethod)
    return source.emitError()
           << "HDL lowering: field '" << fieldNames[fieldIndex]
           << "' is driven from multiple processes ('"
           << methodNames[writer->second] << "' in domain '"
           << domainName(writer->second) << "' and '"
           << methodNames[currentMethod] << "' in domain '"
           << domainName(currentMethod) << "')";
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

/// Make an unwritten register hold its current value instead of zero.
static void setHoldValue(Value reg) {
  if (auto comp = reg.getDefiningOp<seq::CompRegOp>())
    comp->setOperand(0, reg);
  else if (auto fir = reg.getDefiningOp<seq::FirRegOp>())
    fir->setOperand(0, reg);
  else if (auto ce = reg.getDefiningOp<seq::CompRegClockEnabledOp>())
    ce->setOperand(0, reg);
}

Value CirctModuleEmitter::getOrCreateReg(unsigned fieldIndex, Type type) {
  if (auto delayed = delayedNextRegs.find(fieldIndex);
      delayed != delayedNextRegs.end() && !delayed->second.empty())
    return delayed->second.back();
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
  setHoldValue(reg);
  fieldRegs[fieldIndex] = reg;
  fieldNext[fieldIndex] = reg;
  return reg;
}

void CirctModuleEmitter::convertCEToPlain(unsigned fieldIndex,
                                          bool preserveEnable) {
  Value reg = fieldRegs.lookup(fieldIndex);
  auto ce = reg ? reg.getDefiningOp<seq::CompRegClockEnabledOp>() : nullptr;
  if (!ce)
    return;
  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPoint(ce);
  Value input = fieldNext.lookup(fieldIndex);
  // Dropping the clock enable must keep its update path: gate the pending
  // value with the enable and use the current register as the hold value.
  Value enable = preserveEnable ? fieldEnable.lookup(fieldIndex) : Value();
  if (enable && input) {
    input = comb::MuxOp::create(builder, loc, enable, input, ce.getResult());
    fieldNext[fieldIndex] = input;
  }
  auto plain = seq::CompRegOp::create(builder, loc, input, clk, ce.getReset(),
                                      ce.getResetValue(),
                                      ce.getInitialValue());
  ce.getResult().replaceAllUsesWith(plain.getResult());
  ce.erase();
  fieldRegs[fieldIndex] = plain;
}

LogicalResult CirctModuleEmitter::storeField(unsigned fieldIndex, Value value,
                                             Value condition) {
  if (delayedNextRegs.count(fieldIndex))
    return source.emitError()
           << "HDL lowering: cannot mix immediate and delayed next on field '"
           << fieldNames[fieldIndex] << "'";
  if (auto writer = fieldWriter.find(fieldIndex);
      writer != fieldWriter.end() && writer->second != currentMethod)
    return source.emitError()
           << "HDL lowering: field '" << fieldNames[fieldIndex]
           << "' is driven from multiple processes ('"
           << methodNames[writer->second] << "' in domain '"
           << domainName(writer->second) << "' and '"
           << methodNames[currentMethod] << "' in domain '"
           << domainName(currentMethod) << "')";
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
      convertCEToPlain(fieldIndex, /*preserveEnable=*/true);
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
      convertCEToPlain(fieldIndex, /*preserveEnable=*/false);
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

  // Record a value written to the method's by-ref result slot. Inside a
  // branch the site keeps that branch condition, so the final output is a mux
  // over the paths that returned.
  auto recordReturn = [&](Value value, Value xz = Value()) {
    returnSites.push_back({condition, value, xz});
    returnValue = value;
    if (xz) {
      returnXz = xz;
      returnIsLogic = true;
    }
  };

  if (name == "hlcf.yield")
    return success();

  // Emitted after a block where every path returned; the lowering has already
  // recorded those returns.
  if (name == "hlcf.unreachable")
    return success();

  if (name == "hlcf.break") {
    // In a time-multiplexed loop the enclosing conditional records the exit
    // condition; the break itself produces no hardware.
    if (inDynamicLoop)
      return success();
    if (loopStack.empty())
      return op->emitError() << "HDL lowering: break outside a loop";
    loopStack.back().breakTaken = true;
    return success();
  }

  if (name == "hlcf.continue") {
    if (loopStack.empty())
      return op->emitError() << "HDL lowering: continue outside a loop";
    loopStack.back().continueTaken = true;
    return success();
  }

  if (name == "hlcf.loop") {
    if (op->getNumRegions() != 1 || op->getRegion(0).empty())
      return op->emitError() << "HDL lowering: malformed loop";
    if (inDynamicLoop) {
      bool nestedHandled = false;
      if (failed(emitNestedRangeLoop(op, condition, returnValue,
                                     nestedHandled)))
        return failure();
      if (nestedHandled)
        return success();
    }
    bool handled = false;
    if (failed(emitDynamicLoop(op, condition, returnValue, handled)))
      return failure();
    if (!handled &&
        failed(emitRuntimeRangeLoop(op, condition, returnValue, handled)))
      return failure();
    if (handled)
      return success();
    constexpr unsigned kMaxLoopIterations = 4096;
    bool wasUnrolling = inLoopUnroll;
    inLoopUnroll = true;
    for (unsigned iteration = 0; iteration < kMaxLoopIterations;
         ++iteration) {
      loopStack.push_back({});
      LogicalResult result =
          emitBlock(op->getRegion(0).front(), condition, returnValue);
      LoopControl control = loopStack.pop_back_val();
      if (failed(result)) {
        inLoopUnroll = wasUnrolling;
        return failure();
      }
      if (control.breakTaken) {
        inLoopUnroll = wasUnrolling;
        return success();
      }
    }
    inLoopUnroll = wasUnrolling;
    return op->emitError()
           << "HDL lowering: loop did not terminate after "
           << kMaxLoopIterations
           << " iterations; loop bounds must be constant";
  }

  if (name == "hlcf.if") {
    if (op->getNumOperands() != 1 || op->getNumRegions() != 2 ||
        op->getNumResults() != 0)
      return op->emitError()
             << "HDL lowering: unsupported conditional in HDL method";
    std::optional<llvm::APInt> constantCond =
        inLoopUnroll ? resolveConstant(op->getOperand(0)) : std::nullopt;
    Value cond;
    if (!constantCond) {
      cond = getValue(op->getOperand(0));
      if (!cond)
        return op->emitError() << "HDL lowering: condition was not lowered";
    }
    auto hasBody = [](Region &region) {
      if (region.empty())
        return false;
      for (Operation &op : region.front())
        if (op.getName().getStringRef() != "hlcf.yield")
          return true;
      return false;
    };
    Region &thenRegion = op->getRegion(0);
    Region &elseRegion = op->getRegion(1);

    Value savedRelative = loopRelativeCondition;
    Value thenRelative;
    Value elseRelative;
    if (inDynamicLoop) {
      thenRelative = savedRelative
                         ? comb::AndOp::create(builder, loc, savedRelative, cond)
                         : cond;
      Value notCondRelative = bitNot(cond);
      elseRelative =
          savedRelative
              ? comb::AndOp::create(builder, loc, savedRelative,
                                    notCondRelative)
              : notCondRelative;
      auto regionHasBreak = [](Region &region) {
        if (region.empty())
          return false;
        for (Operation &inner : region.front())
          if (inner.getName().getStringRef() == "hlcf.break")
            return true;
        return false;
      };
      if (regionHasBreak(thenRegion))
        dynamicBreakCond =
            dynamicBreakCond
                ? comb::OrOp::create(builder, loc, dynamicBreakCond,
                                     thenRelative)
                : thenRelative;
      if (regionHasBreak(elseRegion))
        dynamicBreakCond =
            dynamicBreakCond
                ? comb::OrOp::create(builder, loc, dynamicBreakCond,
                                     elseRelative)
                : elseRelative;
    }

    // A constant condition in an unrolled loop selects one region directly.
    if (constantCond) {
      bool taken = !constantCond->isZero();
      Region &chosen = taken ? thenRegion : elseRegion;
      if (hasBody(chosen)) {
        branchPath.push_back({Value(), true});
        LogicalResult result =
            emitBlock(chosen.front(), condition, returnValue);
        branchPath.pop_back();
        if (failed(result))
          return failure();
      }
      return success();
    }

    bool hasThen = hasBody(thenRegion);
    bool hasElse = hasBody(elseRegion);

    // A runtime loop inside a branch is branch-local: its done pulse gates
    // the rest of that branch and must not leak out of the `if`. Values of
    // locals that existed before the `if` are merged at the join so a loop's
    // carried result participates in the ordinary branch mux.
    auto regionHasRuntimeLoop = [](Region &region) {
      if (region.empty())
        return false;
      bool found = false;
      region.front().walk([&](Operation *inner) {
        if (inner->getName().getStringRef() == "hlcf.loop")
          found = true;
      });
      return found;
    };
    bool mergeBranchValues =
        regionHasRuntimeLoop(thenRegion) || regionHasRuntimeLoop(elseRegion);

    SmallVector<Value> localSlots;
    DenseMap<Value, Value> savedValues, thenValues, elseValues;
    DenseMap<Value, LogicValue> savedLogic, thenLogic, elseLogic;
    Value thenBranchCond;
    Value elseBranchCond;
    if (mergeBranchValues) {
      localSlots = stackSlots;
      for (Value slot : localSlots) {
        if (auto it = values.find(slot); it != values.end())
          savedValues[slot] = it->second;
        if (auto it = logicValues.find(slot); it != logicValues.end())
          savedLogic[slot] = it->second;
      }
      if (hasThen)
        thenBranchCond = condition
                             ? comb::AndOp::create(builder, loc, condition, cond)
                             : cond;
      if (hasElse) {
        Value notCond = bitNot(cond);
        elseBranchCond =
            condition ? comb::AndOp::create(builder, loc, condition, notCond)
                      : notCond;
      }
    }
    auto captureLocals = [&](DenseMap<Value, Value> &outValues,
                             DenseMap<Value, LogicValue> &outLogic) {
      for (Value slot : localSlots) {
        if (auto it = values.find(slot); it != values.end())
          outValues[slot] = it->second;
        if (auto it = logicValues.find(slot); it != logicValues.end())
          outLogic[slot] = it->second;
      }
    };
    auto restoreLocals = [&]() {
      for (Value slot : localSlots) {
        values.erase(slot);
        logicValues.erase(slot);
        if (auto it = savedValues.find(slot); it != savedValues.end())
          values[slot] = it->second;
        if (auto it = savedLogic.find(slot); it != savedLogic.end())
          logicValues[slot] = it->second;
      }
    };

    Value savedPendingDone = pendingLoopDone;
    Value savedStartPulse = currentStartPulse;

    if (hasThen) {
      Value thenCond =
          mergeBranchValues
              ? thenBranchCond
              : (condition
                     ? comb::AndOp::create(builder, loc, condition, cond)
                     : cond);
      branchPath.push_back({cond, true});
      if (inDynamicLoop)
        loopRelativeCondition = thenRelative;
      LogicalResult result = emitBlock(thenRegion.front(), thenCond, returnValue);
      branchPath.pop_back();
      loopRelativeCondition = savedRelative;
      if (failed(result))
        return failure();
      if (mergeBranchValues)
        captureLocals(thenValues, thenLogic);
    }
    pendingLoopDone = savedPendingDone;
    currentStartPulse = savedStartPulse;
    if (mergeBranchValues)
      restoreLocals();

    if (hasElse) {
      Value elseCond =
          mergeBranchValues
              ? elseBranchCond
              : (condition
                     ? comb::AndOp::create(
                           builder, loc, condition, bitNot(cond))
                     : bitNot(cond));
      branchPath.push_back({cond, false});
      if (inDynamicLoop)
        loopRelativeCondition = elseRelative;
      LogicalResult result = emitBlock(elseRegion.front(), elseCond, returnValue);
      branchPath.pop_back();
      loopRelativeCondition = savedRelative;
      if (failed(result))
        return failure();
      if (mergeBranchValues)
        captureLocals(elseValues, elseLogic);
    }
    pendingLoopDone = savedPendingDone;
    currentStartPulse = savedStartPulse;

    if (mergeBranchValues) {
      for (Value slot : localSlots) {
        auto beforeV = savedValues.find(slot);
        auto thenV = thenValues.find(slot);
        auto elseV = elseValues.find(slot);
        auto beforeL = savedLogic.find(slot);
        auto thenL = thenLogic.find(slot);
        auto elseL = elseLogic.find(slot);
        bool bitsChanged =
            (hasThen && thenV != thenValues.end() &&
             (beforeV == savedValues.end() ||
              thenV->second != beforeV->second)) ||
            (hasElse && elseV != elseValues.end() &&
             (beforeV == savedValues.end() ||
              elseV->second != beforeV->second));
        bool logicChanged =
            (hasThen && thenL != thenLogic.end() &&
             (beforeL == savedLogic.end() ||
              thenL->second.val != beforeL->second.val ||
              thenL->second.xz != beforeL->second.xz)) ||
            (hasElse && elseL != elseLogic.end() &&
             (beforeL == savedLogic.end() ||
              elseL->second.val != beforeL->second.val ||
              elseL->second.xz != beforeL->second.xz));
        if (logicChanged) {
          LogicValue merged;
          if (beforeL != savedLogic.end())
            merged = beforeL->second;
          if (hasElse && elseL != elseLogic.end()) {
            merged.val =
                merged.val ? comb::MuxOp::create(builder, loc, elseBranchCond,
                                                 elseL->second.val, merged.val)
                           : elseL->second.val;
            merged.xz =
                merged.xz ? comb::MuxOp::create(builder, loc, elseBranchCond,
                                                elseL->second.xz, merged.xz)
                          : elseL->second.xz;
          }
          if (hasThen && thenL != thenLogic.end()) {
            merged.val =
                merged.val ? comb::MuxOp::create(builder, loc, thenBranchCond,
                                                 thenL->second.val, merged.val)
                           : thenL->second.val;
            merged.xz =
                merged.xz ? comb::MuxOp::create(builder, loc, thenBranchCond,
                                                thenL->second.xz, merged.xz)
                          : thenL->second.xz;
          }
          logicValues[slot] = merged;
          values[slot] = merged.val;
          continue;
        }
        if (!bitsChanged)
          continue;
        Value merged;
        if (beforeV != savedValues.end())
          merged = beforeV->second;
        if (hasElse && elseV != elseValues.end())
          merged =
              merged ? comb::MuxOp::create(builder, loc, elseBranchCond,
                                           elseV->second, merged)
                     : elseV->second;
        if (hasThen && thenV != thenValues.end())
          merged =
              merged ? comb::MuxOp::create(builder, loc, thenBranchCond,
                                           thenV->second, merged)
                     : thenV->second;
        if (merged)
          values[slot] = merged;
        else
          values.erase(slot);
      }
    }
    return success();
  }

  if (name == "hlcf.return") {
    if (op->getNumOperands() == 1)
      if (Value value = getValue(op->getOperand(0)))
        recordReturn(value);
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
    StringRef userCallName = callee.split('(').first;
    if (!userCallName.contains("hdl::") && !userCallName.contains("std::") &&
        userCallName.ends_with("::__init__") && op->getNumOperands() >= 2) {
      // A constructor of a struct local: dispatch before the generic binary
      // call path, which would treat a two-operand constructor as arithmetic.
      Value destination = op->getOperand(op->getNumOperands() - 1);
      if (llvm::is_contained(stackSlots, destination) ||
          structFieldPaths.count(destination))
        return emitStructConstructor(op, callee, condition, returnValue);
    }
    if (!userCallName.contains("hdl::") && !userCallName.contains("std::") &&
        !userCallName.ends_with("::__init__") &&
        !userCallName.ends_with("::__copyinit__") &&
        !userCallName.ends_with("::__moveinit__") &&
        op->getNumOperands() >= 1 &&
        llvm::is_contained(stackSlots, op->getOperand(0)))
      return emitStructMethod(op, callee, condition, returnValue);

    auto constantIndex = [](Value value) -> std::optional<uint64_t> {
      if (auto constant = value.getDefiningOp<hw::ConstantOp>())
        return constant.getValue().getZExtValue();
      return std::nullopt;
    };

    auto arrayWrite = [&](unsigned field, Value index, Value data, Value dataXz,
                          bool isLogic, Value enable,
                          Value condition) -> LogicalResult {
      if (auto writer = fieldWriter.find(field);
          writer != fieldWriter.end() && writer->second != currentMethod)
        return op->emitError()
               << "HDL lowering: memory '" << fieldNames[field]
               << "' is written from process '" << methodNames[currentMethod]
               << "' (domain '" << domainName(currentMethod)
               << "') but driven from '" << methodNames[writer->second]
               << "' (domain '" << domainName(writer->second)
               << "'); the access crosses clock domains";
      fieldWriter[field] = currentMethod;
      auto &regs = getOrCreateArrayStorage(field);
      if (regs.empty())
        return op->emitError() << "HDL lowering: empty array storage";
      auto constIdx = constantIndex(index);
      if (constIdx && *constIdx >= regs.size())
        return op->emitError() << "HDL lowering: array index out of range";
      auto &nexts = arrayNext[field];
      auto &xzNexts = arrayXzNext[field];
      auto &enables = arrayEnable[field];
      auto &written = arrayWritten[field];
      auto setEntry = [&](Value reg, Value next,
                          Value en) -> LogicalResult {
        if (auto ceOp = reg.getDefiningOp<seq::CompRegClockEnabledOp>()) {
          ceOp->setOperand(0, next);
          ceOp->setOperand(2, en);
        } else if (auto fir = reg.getDefiningOp<seq::FirRegOp>()) {
          fir->setOperand(0, next);
        } else {
          return op->emitError()
                 << "HDL lowering: unsupported array register form";
        }
        return success();
      };

      for (unsigned k = 0; k < regs.size(); ++k) {
        if (constIdx && *constIdx != k)
          continue;
        Value ce;
        if (constIdx) {
          ce = enable ? enable : getConstant(true);
        } else {
          Value eq = comb::ICmpOp::create(
              builder, loc, comb::ICmpPredicate::eq, index,
              hw::ConstantOp::create(builder, loc, index.getType(),
                                     static_cast<int64_t>(k)));
          ce = enable ? comb::AndOp::create(builder, loc, enable, eq) : eq;
        }
        if (condition)
          ce = comb::AndOp::create(builder, loc, condition, ce);

        bool clockEnabled =
            regs[k].getDefiningOp<seq::CompRegClockEnabledOp>() != nullptr;
        Value next = data;
        Value nextXz = isLogic ? dataXz : Value();
        Value combinedEnable = ce;
        if (!written[k] && clockEnabled) {
          // The first write to a clock-enabled entry needs no input mux.
        } else {
          next = comb::MuxOp::create(builder, loc, ce, data, nexts[k]);
          if (isLogic)
            nextXz = comb::MuxOp::create(builder, loc, ce, dataXz, xzNexts[k]);
          if (written[k])
            combinedEnable =
                comb::OrOp::create(builder, loc, enables[k], ce);
        }
        written[k] = true;
        nexts[k] = next;
        if (isLogic)
          xzNexts[k] = nextXz;
        enables[k] = combinedEnable;

        if (failed(setEntry(regs[k], next, combinedEnable)))
          return failure();
        if (isLogic && failed(setEntry(arrayXzRegs[field][k], nextXz,
                                       combinedEnable)))
          return failure();
      }
      return success();
    };

    auto arrayRead = [&](unsigned field, Value index, bool isLogic,
                         Value &resultXz) -> Value {
      fieldReaders[field].insert(currentMethod);
      auto &regs = getOrCreateArrayStorage(field);
      if (regs.empty())
        return {};
      auto constIdx = constantIndex(index);
      if (constIdx) {
        if (*constIdx >= regs.size())
          return {};
        if (isLogic)
          resultXz = arrayXzRegs[field][*constIdx];
        return regs[*constIdx];
      }
      Value result = regs[0];
      if (isLogic)
        resultXz = arrayXzRegs[field][0];
      for (unsigned k = 1; k < regs.size(); ++k) {
        Value eq = comb::ICmpOp::create(
            builder, loc, comb::ICmpPredicate::eq, index,
            hw::ConstantOp::create(builder, loc, index.getType(),
                                   static_cast<int64_t>(k)));
        result = comb::MuxOp::create(builder, loc, eq, regs[k], result);
        if (isLogic)
          resultXz = comb::MuxOp::create(
              builder, loc, eq, arrayXzRegs[field][k], resultXz);
      }
      return result;
    };

    auto setRegisterNext = [&](Value reg,
                               Value next) -> LogicalResult {
      if (auto cr = reg.getDefiningOp<seq::CompRegOp>())
        cr->setOperand(0, next);
      else if (auto ce = reg.getDefiningOp<seq::CompRegClockEnabledOp>())
        ce->setOperand(0, next);
      else if (auto fr = reg.getDefiningOp<seq::FirRegOp>())
        fr->setOperand(0, next);
      else
        return op->emitError()
               << "HDL lowering: unsupported delay register form";
      return success();
    };

    auto delayedWrite = [&](unsigned field, unsigned delay, Value value,
                            Value condition) -> LogicalResult {
      if (delay <= 1)
        return storeField(field, value, condition);
      if (auto writer = fieldWriter.find(field);
          writer != fieldWriter.end() && writer->second != currentMethod)
        return op->emitError()
               << "HDL lowering: field '" << fieldNames[field]
               << "' is driven from multiple processes";
      fieldWriter[field] = currentMethod;
      if (delayedNextRegs.count(field))
        return op->emitError()
               << "HDL lowering: multiple delayed next on field '"
               << fieldNames[field] << "'";

      unsigned width = fieldWidths[field];
      auto type = IntegerType::get(builder.getContext(), width);
      llvm::APInt resetBits(width, 0);
      if (auto value = resetValues.find(field); value != resetValues.end())
        resetBits = value->second.zextOrTrunc(width);
      llvm::APInt initialBits = resetBits;
      if (powerOnValue)
        initialBits = powerOnValue->zextOrTrunc(width);
      int style = field < fieldResetStyle.size() ? fieldResetStyle[field]
                                                 : resetStyle;
      auto &chain = delayedNextRegs[field];
      for (unsigned stage = 0; stage < delay; ++stage) {
        unsigned id = 100000 + field * 100 + stage;
        Value reg = createRegister(id, type, resetBits, initialBits, style);
        Value next = stage == 0 ? value : chain[stage - 1];
        if (stage == 0 && condition)
          next = comb::MuxOp::create(builder, loc, condition, next, reg);
        if (failed(setRegisterNext(reg, next)))
          return failure();
        chain.push_back(reg);
      }
      return success();
    };

    auto pastValue = [&](unsigned field, unsigned delay) -> Value {
      unsigned width = fieldWidths[field];
      auto type = IntegerType::get(builder.getContext(), width);
      Value current = getOrCreateReg(field, type);
      if (!current || delay == 0)
        return current;
      auto &chain = pastChains[field][delay];
      if (!chain.empty())
        return chain.back();
      llvm::APInt resetBits(width, 0);
      if (auto value = resetValues.find(field); value != resetValues.end())
        resetBits = value->second.zextOrTrunc(width);
      llvm::APInt initialBits = resetBits;
      if (powerOnValue)
        initialBits = powerOnValue->zextOrTrunc(width);
      int style = field < fieldResetStyle.size() ? fieldResetStyle[field]
                                                 : resetStyle;
      for (unsigned stage = 0; stage < delay; ++stage) {
        unsigned id = 200000 + field * 1000 + delay * 10 + stage;
        Value reg = createRegister(id, type, resetBits, initialBits, style);
        Value next = stage == 0 ? current : chain[stage - 1];
        if (failed(setRegisterNext(reg, next)))
          return {};
        chain.push_back(reg);
      }
      return chain.back();
    };

    auto delayedLogicWrite = [&](unsigned field, unsigned delay,
                                 LogicValue value,
                                 Value condition) -> LogicalResult {
      if (delay <= 1)
        return storeLogicField(field, value, condition);
      if (auto writer = fieldWriter.find(field);
          writer != fieldWriter.end() && writer->second != currentMethod)
        return op->emitError()
               << "HDL lowering: Logic field '" << fieldNames[field]
               << "' is driven from multiple processes";
      fieldWriter[field] = currentMethod;
      if (delayedLogicNextRegs.count(field))
        return op->emitError()
               << "HDL lowering: multiple delayed next on Logic field '"
               << fieldNames[field] << "'";

      unsigned width = value.val.getType().getIntOrFloatBitWidth();
      auto type = IntegerType::get(builder.getContext(), width);
      llvm::APInt resetBits(width, 0);
      if (auto reset = resetValues.find(field); reset != resetValues.end())
        resetBits = reset->second.zextOrTrunc(width);
      llvm::APInt initialBits = resetBits;
      if (powerOnValue)
        initialBits = powerOnValue->zextOrTrunc(width);
      llvm::APInt zeroBits(width, 0);
      int style = field < fieldResetStyle.size() ? fieldResetStyle[field]
                                                 : resetStyle;
      auto &chain = delayedLogicNextRegs[field];
      for (unsigned stage = 0; stage < delay; ++stage) {
        unsigned id = 300000 + field * 100 + stage * 2;
        Value valReg =
            createRegister(id, type, resetBits, initialBits, style);
        Value xzReg = createRegister(id + 1, type, zeroBits, zeroBits, style);
        LogicValue regs{valReg, xzReg};
        Value nextVal = stage == 0 ? value.val : chain[stage - 1].val;
        Value nextXz = stage == 0 ? value.xz : chain[stage - 1].xz;
        if (stage == 0 && condition) {
          nextVal = comb::MuxOp::create(builder, loc, condition, nextVal,
                                        valReg);
          nextXz = comb::MuxOp::create(builder, loc, condition, nextXz,
                                       xzReg);
        }
        if (failed(setRegisterNext(valReg, nextVal)) ||
            failed(setRegisterNext(xzReg, nextXz)))
          return failure();
        chain.push_back(regs);
      }
      return success();
    };

    auto pastLogicValue = [&](unsigned field,
                              unsigned delay) -> LogicValue {
      unsigned width = fieldWidths[field];
      LogicValue current = getOrCreateLogicReg(field, width);
      if (!current || delay == 0)
        return current;
      auto &chain = pastLogicChains[field][delay];
      if (!chain.empty())
        return chain.back();
      auto type = IntegerType::get(builder.getContext(), width);
      llvm::APInt resetBits(width, 0);
      if (auto reset = resetValues.find(field); reset != resetValues.end())
        resetBits = reset->second.zextOrTrunc(width);
      llvm::APInt initialBits = resetBits;
      if (powerOnValue)
        initialBits = powerOnValue->zextOrTrunc(width);
      llvm::APInt zeroBits(width, 0);
      int style = field < fieldResetStyle.size() ? fieldResetStyle[field]
                                                 : resetStyle;
      for (unsigned stage = 0; stage < delay; ++stage) {
        unsigned id = 400000 + field * 1000 + delay * 20 + stage * 2;
        Value valReg =
            createRegister(id, type, resetBits, initialBits, style);
        Value xzReg = createRegister(id + 1, type, zeroBits, zeroBits, style);
        LogicValue regs{valReg, xzReg};
        Value nextVal = stage == 0 ? current.val : chain[stage - 1].val;
        Value nextXz = stage == 0 ? current.xz : chain[stage - 1].xz;
        if (failed(setRegisterNext(valReg, nextVal)) ||
            failed(setRegisterNext(xzReg, nextXz)))
          return {};
        chain.push_back(regs);
      }
      return chain.back();
    };

    // A direct `Array::__setitem__` writes one storage slot. In practice the
    // elaborator often forwards a `Reg` construction into the element, but
    // this handles the explicit setter form too.
    if (callee.contains("Array::__setitem__")) {
      if (op->getNumOperands() != 3)
        return op->emitError()
               << "HDL lowering: unexpected Array::__setitem__ form";
      auto array = fieldPtrs.find(op->getOperand(0));
      bool isStorage = array != fieldPtrs.end() &&
                       array->second < fieldIsArrayStorage.size() &&
                       fieldIsArrayStorage[array->second];
      if (!isStorage) {
        // A payload array is one packed value: replace the selected lane.
        Type elemType = getCallTypeParam(op, 0);
        unsigned laneWidth = getHdlWidth(elemType, &bindings);
        bool logicArray = elemType && isLogicType(elemType);
        Value self = op->getOperand(0);
        Value index = getValue(op->getOperand(1));
        if (!laneWidth || !index)
          return op->emitError()
                 << "HDL lowering: unsupported Array element access";
        auto resize = [&](Value value, unsigned width) -> Value {
          unsigned current = value.getType().getIntOrFloatBitWidth();
          if (current == width)
            return value;
          if (current < width) {
            Value zeros = hw::ConstantOp::create(
                builder, loc, llvm::APInt(width - current, 0));
            return comb::ConcatOp::create(builder, loc,
                                          ArrayRef<Value>{zeros, value});
          }
          return comb::ExtractOp::create(builder, loc, value, 0, width);
        };
        unsigned packedWidth =
            logicArray ? getLogicValue(self).val.getType().getIntOrFloatBitWidth()
                       : getValue(self).getType().getIntOrFloatBitWidth();
        Value shift = resize(index, packedWidth);
        Value laneWidthValue = hw::ConstantOp::create(
            builder, loc, llvm::APInt(packedWidth, laneWidth));
        Value offset =
            comb::MulOp::create(builder, loc, shift, laneWidthValue);
        Value mask = hw::ConstantOp::create(
            builder, loc, llvm::APInt::getLowBitsSet(packedWidth, laneWidth));
        Value shiftedMask = comb::ShlOp::create(builder, loc, mask, offset);
        auto insertLane = [&](Value word, Value lane) -> Value {
          Value wide = resize(lane, packedWidth);
          Value shiftedValue =
              comb::ShlOp::create(builder, loc, wide, offset);
          Value cleared =
              comb::AndOp::create(builder, loc, word, bitNot(shiftedMask));
          return comb::OrOp::create(builder, loc, cleared, shiftedValue);
        };
        if (logicArray) {
          LogicValue packed = getLogicValue(self);
          LogicValue value = getLogicValue(op->getOperand(2));
          if (!packed || !value)
            return op->emitError()
                   << "HDL lowering: Array element value was not lowered";
          LogicValue updated{insertLane(packed.val, value.val),
                             insertLane(packed.xz, value.xz)};
          if (storeLoopCarriedLogic(self, updated, condition))
            return success();
          if (array != fieldPtrs.end())
            return storeLogicField(array->second, updated, condition);
          values[self] = updated.val;
          logicValues[self] = updated;
          return success();
        }
        Value packed = getValue(self);
        Value value = getValue(op->getOperand(2));
        if (!packed || !value)
          return op->emitError()
                 << "HDL lowering: Array element operand was not lowered";
        Value updated = insertLane(packed, value);
        if (storeLoopCarried(self, updated, condition))
          return success();
        if (array != fieldPtrs.end())
          return storeField(array->second, updated, condition);
        values[self] = updated;
        return success();
      }
      unsigned field = array->second;
      Value index = getValue(op->getOperand(1));
      if (!index)
        return op->emitError()
               << "HDL lowering: array index was not lowered";
      bool isLogic = arrayIsLogic.lookup(field);
      if (isLogic) {
        LogicValue value = getLogicValue(op->getOperand(2));
        if (!value)
          return op->emitError()
                 << "HDL lowering: array element value was not lowered";
        return arrayWrite(field, index, value.val, value.xz, true, Value(),
                          condition);
      }
      Value value = getValue(op->getOperand(2));
      if (!value)
        return op->emitError()
               << "HDL lowering: array element value was not lowered";
      return arrayWrite(field, index, value, Value(), false, Value(),
                        condition);
    }

    // A constant-index access lowers to `__getitem_param__`; recover the
    // compile-time index and record the same element access.
    if (callee.contains("Array::__getitem_param__")) {
      if (op->getNumOperands() != 1)
        return op->emitError()
               << "HDL lowering: unexpected Array::__getitem_param__ form";
      auto array = fieldPtrs.find(op->getOperand(0));
      bool isStorage = array != fieldPtrs.end() &&
                       array->second < fieldIsArrayStorage.size() &&
                       fieldIsArrayStorage[array->second];
      auto indexValue = getCallIntParam(op, 2, &bindings);
      if (!indexValue)
        return op->emitError()
               << "HDL lowering: array index was not resolved";
      if (!isStorage) {
        Type elemType = getCallTypeParam(op, 0);
        unsigned laneWidth = getHdlWidth(elemType, &bindings);
        bool logicArray = elemType && isLogicType(elemType);
        Value self = op->getOperand(0);
        if (!laneWidth)
          return op->emitError()
                 << "HDL lowering: unsupported Array element access";
        uint64_t lane = indexValue->getZExtValue();
        if (logicArray) {
          LogicValue packed = getLogicValue(self);
          if (!packed)
            return op->emitError()
                   << "HDL lowering: Array operand was not lowered";
          LogicValue result{
              comb::ExtractOp::create(builder, loc, packed.val,
                                      static_cast<int32_t>(lane * laneWidth),
                                      laneWidth),
              comb::ExtractOp::create(builder, loc, packed.xz,
                                      static_cast<int32_t>(lane * laneWidth),
                                      laneWidth)};
          logicValues[op->getResult(0)] = result;
          return success();
        }
        Value packed = getValue(self);
        if (!packed)
          return op->emitError()
                 << "HDL lowering: Array operand was not lowered";
        values[op->getResult(0)] = comb::ExtractOp::create(
            builder, loc, packed, static_cast<int32_t>(lane * laneWidth),
            laneWidth);
        return success();
      }
      Value index = hw::ConstantOp::create(
          builder, loc, builder.getI64Type(),
          static_cast<int64_t>(indexValue->getZExtValue()));
      arrayElements[op->getResult(0)] = {array->second, index};
      return success();
    }

    // `Array[Reg[T], N].__getitem__` yields a pointer to one storage slot.
    // Record it so the following `Reg` operation can lower against the slot.
    if (callee.contains("Array::__getitem__")) {
      if (op->getNumOperands() != 2)
        return op->emitError()
               << "HDL lowering: unexpected Array::__getitem__ form";
      auto array = fieldPtrs.find(op->getOperand(0));
      bool isStorage = array != fieldPtrs.end() &&
                       array->second < fieldIsArrayStorage.size() &&
                       fieldIsArrayStorage[array->second];
      Value index = getValue(op->getOperand(1));
      if (!index)
        return op->emitError()
               << "HDL lowering: array index was not lowered";
      if (!isStorage) {
        Type elemType = getCallTypeParam(op, 0);
        unsigned laneWidth = getHdlWidth(elemType, &bindings);
        bool logicArray = elemType && isLogicType(elemType);
        Value self = op->getOperand(0);
        if (!laneWidth)
          return op->emitError()
                 << "HDL lowering: unsupported Array element access";
        auto extractLane = [&](Value word) -> Value {
          unsigned packedWidth = word.getType().getIntOrFloatBitWidth();
          Value shift = index;
          unsigned indexWidth = shift.getType().getIntOrFloatBitWidth();
          if (indexWidth > packedWidth)
            shift = comb::ExtractOp::create(builder, loc, shift, 0,
                                            packedWidth);
          else if (indexWidth < packedWidth) {
            Value zeros = hw::ConstantOp::create(
                builder, loc, llvm::APInt(packedWidth - indexWidth, 0));
            shift = comb::ConcatOp::create(
                builder, loc, ArrayRef<Value>{zeros, shift});
          }
          Value laneWidthValue = hw::ConstantOp::create(
              builder, loc, llvm::APInt(packedWidth, laneWidth));
          Value offset =
              comb::MulOp::create(builder, loc, shift, laneWidthValue);
          Value shifted = comb::ShrUOp::create(builder, loc, word, offset);
          return comb::ExtractOp::create(builder, loc, shifted, 0, laneWidth);
        };
        if (logicArray) {
          LogicValue packed = getLogicValue(self);
          if (!packed)
            return op->emitError()
                   << "HDL lowering: Array operand was not lowered";
          LogicValue result{extractLane(packed.val), extractLane(packed.xz)};
          logicValues[op->getResult(0)] = result;
          return success();
        }
        Value packed = getValue(self);
        if (!packed)
          return op->emitError()
                 << "HDL lowering: Array operand was not lowered";
        values[op->getResult(0)] = extractLane(packed);
        return success();
      }
      arrayElements[op->getResult(0)] = {array->second, index};
      return success();
    }

    // `ArrayRam[T, N]` lowers to one array-typed register plus
    // `hw.array_get`/`hw.array_inject` and a write-enable mux. This is the
    // form CIRCT's `seq-reg-of-vec-to-mem` recognizes.
    if (callee.contains("ArrayRam::write") || callee.contains("ArrayRam::read")) {
      if (op->getNumOperands() < 3)
        return op->emitError() << "HDL lowering: malformed ArrayRam access";
      auto array = fieldPtrs.find(op->getOperand(0));
      if (array == fieldPtrs.end() ||
          array->second >= fieldIsArrayStorage.size() ||
          !arrayIsArrayRam.lookup(array->second))
        return op->emitError()
               << "HDL lowering: ArrayRam access on a non-ArrayRam field";
      unsigned field = array->second;
      if (arrayIsLogic.lookup(field))
        return op->emitError()
               << "HDL lowering: ArrayRam[Logic[W], N] is not supported yet";
      Value index = getValue(op->getOperand(1));
      if (!index)
        return op->emitError() << "HDL lowering: ArrayRam index was not lowered";
      unsigned depth = fieldArrayDepths[field];
      unsigned indexWidth = 1;
      while (indexWidth < 64 && (uint64_t(1) << indexWidth) < depth)
        ++indexWidth;
      Value arrayIndex = index;
      unsigned valueWidth = index.getType().getIntOrFloatBitWidth();
      if (valueWidth > indexWidth) {
        arrayIndex = comb::ExtractOp::create(builder, loc, index, 0,
                                             indexWidth);
      } else if (valueWidth < indexWidth) {
        Value zeros = hw::ConstantOp::create(
            builder, loc, llvm::APInt(indexWidth - valueWidth, 0));
        arrayIndex = comb::ConcatOp::create(
            builder, loc, ArrayRef<Value>{zeros, arrayIndex});
      }
      Value reg = getOrCreateArrayRam(field);
      unsigned width = fieldArrayWidths[field];
      auto elementType = IntegerType::get(builder.getContext(), width);
      auto arrayType = hw::ArrayType::get(elementType, depth);

      if (callee.contains("ArrayRam::write")) {
        if (auto writer = fieldWriter.find(field);
            writer != fieldWriter.end() && writer->second != currentMethod)
          return op->emitError()
                 << "HDL lowering: memory '" << fieldNames[field]
                 << "' is written from process '" << methodNames[currentMethod]
                 << "' (domain '" << domainName(currentMethod)
                 << "') but driven from '" << methodNames[writer->second]
                 << "' (domain '" << domainName(writer->second)
                 << "'); the access crosses clock domains";
        fieldWriter[field] = currentMethod;
        if (arrayRamWritten.lookup(field))
          return op->emitError()
                 << "HDL lowering: multiple ArrayRam writes are not supported";
        Value data = getValue(op->getOperand(2));
        if (!data)
          return op->emitError()
                 << "HDL lowering: ArrayRam write data was not lowered";
        Value enable = getConstant(true);
        if (op->getNumOperands() > 3) {
          enable = getValue(op->getOperand(3));
          if (!enable)
            return op->emitError()
                   << "HDL lowering: ArrayRam write enable was not lowered";
        }
        Value injected = hw::ArrayInjectOp::create(
            builder, loc, reg, arrayIndex, data);
        Value next = comb::MuxOp::create(builder, loc, enable, injected, reg);
        reg.getDefiningOp()->setOperand(0, next);
        arrayRamWritten[field] = true;
        return success();
      }

      fieldReaders[field].insert(currentMethod);
      Value readData = hw::ArrayGetOp::create(builder, loc, reg, arrayIndex);
      Value dest = op->getOperand(2);
      values[dest] = readData;
      if (dest == resultPtr)
        recordReturn(readData);
      return success();
    }

    // An explicit `Ram[T, N]` lowers to `seq.hlmem` with read/write ports.
    if (callee.contains("Ram::write") || callee.contains("Ram::read")) {
      if (op->getNumOperands() < 3)
        return op->emitError() << "HDL lowering: malformed RAM access";
      auto ram = fieldPtrs.find(op->getOperand(0));
      if (ram == fieldPtrs.end() ||
          ram->second >= fieldIsArrayStorage.size() ||
          !arrayIsExplicitRam.lookup(ram->second))
        return op->emitError()
               << "HDL lowering: RAM access on a non-RAM field";
      unsigned field = ram->second;
      if (arrayIsLogic.lookup(field))
        return op->emitError()
               << "HDL lowering: Ram[Logic[W], N] is not supported yet";
      Value index = getValue(op->getOperand(1));
      if (!index)
        return op->emitError() << "HDL lowering: RAM index was not lowered";
      unsigned depth = fieldArrayDepths[field];
      unsigned addrWidth = 1;
      while (addrWidth < 64 && (uint64_t(1) << addrWidth) < depth)
        ++addrWidth;
      Value addr = index;
      if (index.getType().getIntOrFloatBitWidth() != addrWidth)
        addr = comb::ExtractOp::create(builder, loc, index, 0, addrWidth);
      Value mem = getOrCreateHLMem(field);

      if (callee.contains("Ram::write")) {
        if (auto writer = fieldWriter.find(field);
            writer != fieldWriter.end() && writer->second != currentMethod)
          return op->emitError()
                 << "HDL lowering: memory '" << fieldNames[field]
                 << "' is written from process '" << methodNames[currentMethod]
                 << "' (domain '" << domainName(currentMethod)
                 << "') but driven from '" << methodNames[writer->second]
                 << "' (domain '" << domainName(writer->second)
                 << "'); the access crosses clock domains";
        fieldWriter[field] = currentMethod;
        Value data = getValue(op->getOperand(2));
        if (!data)
          return op->emitError()
                 << "HDL lowering: RAM write data was not lowered";
        Value enable = getConstant(true);
        if (op->getNumOperands() > 3) {
          enable = getValue(op->getOperand(3));
          if (!enable)
            return op->emitError()
                   << "HDL lowering: RAM write enable was not lowered";
        }
        seq::WritePortOp::create(builder, loc, mem, {addr}, data, enable, 1);
        return success();
      }

      fieldReaders[field].insert(currentMethod);
      Value readData = seq::ReadPortOp::create(
                            builder, loc, mem, {addr}, getConstant(true), 0)
                           .getReadData();
      Value dest = op->getOperand(2);
      values[dest] = readData;
      if (dest == resultPtr)
        recordReturn(readData);
      return success();
    }

    // `Mem[T, N]` is sugar over `Array[Reg[T], N]`: both use the same array
    // storage and address-decode helpers. `T` may be `Bits[W]` or `Logic[W]`.
    if (callee.contains("Mem::write") || callee.contains("Mem::read")) {
      if (op->getNumOperands() < 3)
        return op->emitError() << "HDL lowering: malformed memory access";
      auto mem = fieldPtrs.find(op->getOperand(0));
      if (mem == fieldPtrs.end() ||
          mem->second >= fieldIsArrayStorage.size() ||
          !fieldIsArrayStorage[mem->second])
        return op->emitError()
               << "HDL lowering: memory access on a non-array field";
      unsigned field = mem->second;
      bool isLogic = arrayIsLogic.lookup(field);
      Value index = getValue(op->getOperand(1));
      if (!index)
        return op->emitError()
               << "HDL lowering: memory index was not lowered";

      if (callee.contains("Mem::write")) {
        Value data;
        Value dataXz;
        if (isLogic) {
          LogicValue value = getLogicValue(op->getOperand(2));
          if (!value)
            return op->emitError()
                   << "HDL lowering: memory write data was not lowered";
          data = value.val;
          dataXz = value.xz;
        } else {
          data = getValue(op->getOperand(2));
          if (!data)
            return op->emitError()
                   << "HDL lowering: memory write data was not lowered";
        }
        Value enable;
        if (op->getNumOperands() > 3) {
          enable = getValue(op->getOperand(3));
          if (!enable)
            return op->emitError()
                   << "HDL lowering: memory write enable was not lowered";
        }
        return arrayWrite(field, index, data, dataXz, isLogic, enable,
                          condition);
      }

      Value resultXz;
      Value result = arrayRead(field, index, isLogic, resultXz);
      if (!result)
        return op->emitError() << "HDL lowering: empty memory";
      Value dest = op->getOperand(2);
      if (isLogic) {
        logicValues[dest] = {result, resultXz};
        if (dest == resultPtr)
          recordReturn(result, resultXz);
      } else {
        values[dest] = result;
        if (dest == resultPtr)
          recordReturn(result);
      }
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
        bool childHasClock = false;
        for (hw::PortInfo port : child.getPortList())
          if (port.dir == hw::ModulePort::Direction::Input &&
              isa<seq::ClockType>(port.type))
            childHasClock = true;
        if (childHasClock) {
          if (auto owner = instanceMethod.find(fieldIndex);
              owner != instanceMethod.end() &&
              owner->second != currentMethod)
            return op->emitError()
                   << "HDL lowering: instance '" << fieldNames[fieldIndex]
                   << "' is ticked from multiple processes ('"
                   << methodNames[owner->second] << "' and '"
                   << methodNames[currentMethod] << "')";
          instanceMethod[fieldIndex] = currentMethod;
        }
        MLIRContext *ctx = source.getContext();
        SmallVector<hw::PortInfo> childInputs;
        for (hw::PortInfo port : child.getPortList())
          if (port.dir == hw::ModulePort::Direction::Input)
            childInputs.push_back(port);

        SmallVector<Value> inputs;
        // Operand slot and lowered value for each non-clock/reset input, used
        // to mux a second tick from a mutually exclusive branch.
        SmallVector<std::pair<unsigned, Value>> dataInputs;
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
            dataInputs.push_back({inputs.size() - 1, value.val});
            inputs.push_back(value.xz);
            dataInputs.push_back({inputs.size() - 1, value.xz});
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
          dataInputs.push_back({inputs.size() - 1, value});
        }
        if (operandIndex + 1 != op->getNumOperands())
          return op->emitError()
                 << "HDL lowering: too many instance operands";

        // The by-ref result slot of a tick is either a temporary (bound as a
        // value) or a `self.<field>` pointer, in which case the call stores
        // the result into the field through the normal register path.
        auto bindResult = [&](Value dest, Value value, Value xz) -> LogicalResult {
          if (auto field = fieldPtrs.find(dest); field != fieldPtrs.end()) {
            bool logicField = field->second < fieldIsLogic.size() &&
                              fieldIsLogic[field->second];
            if (logicField) {
              if (!xz)
                return op->emitError()
                       << "HDL lowering: Logic instance result has no mask";
              return storeLogicField(field->second, {value, xz}, condition);
            }
            return storeField(field->second, value, condition);
          }
          if (xz) {
            logicValues[dest] = {value, xz};
            if (dest == resultPtr)
              recordReturn(value, xz);
          } else {
            values[dest] = value;
            if (dest == resultPtr)
              recordReturn(value);
          }
          return success();
        };

        // A stateful child ticked once per branch of the same `if`/`else`
        // chain is a single instance: its inputs are muxed on the branch
        // condition and each call site sees its own gated result. Overlapping
        // call sites (the same branch, or two unconditional ticks) stay
        // errors.
        auto existing = instanceCalls.find(fieldIndex);
        if (existing != instanceCalls.end() && childHasClock) {
          InstanceCallState &state = existing->second;
          for (const auto &path : state.paths)
            if (!pathsExclusive(path, branchPath))
              return op->emitError()
                     << "HDL lowering: instance '" << fieldNames[fieldIndex]
                     << "' is ticked more than once in process '"
                     << methodNames[currentMethod]
                     << "' (branches are not mutually exclusive)";
          for (auto &[index, value] : dataInputs) {
            Value previous = state.op->getOperand(index);
            state.op->setOperand(
                index, comb::MuxOp::create(builder, loc, condition, value,
                                           previous));
          }
          state.paths.push_back(branchPath);

          Value dest = op->getOperand(op->getNumOperands() - 1);
          auto gate = [&](Value value) -> Value {
            auto integer = dyn_cast<IntegerType>(value.getType());
            if (!integer)
              return value;
            Value zero = hw::ConstantOp::create(builder, loc, integer, 0);
            return comb::MuxOp::create(builder, loc, condition, value, zero);
          };
          if (state.results == 1)
            return bindResult(dest, gate(state.op->getResult(0)), Value());
          if (state.results == 2)
            return bindResult(dest, gate(state.op->getResult(0)),
                              gate(state.op->getResult(1)));
          return op->emitError()
                 << "HDL lowering: instance with " << state.results
                 << " outputs is not supported";
        }

        auto instanceOp = hw::InstanceOp::create(
            builder, loc, childOp,
            StringAttr::get(ctx, fieldNames[fieldIndex]), inputs);
        if (childHasClock) {
          InstanceCallState &state = instanceCalls[fieldIndex];
          state.op = instanceOp;
          state.results = instanceOp.getNumResults();
          state.paths.push_back(branchPath);
        }

        Value dest = op->getOperand(op->getNumOperands() - 1);
        auto gate = [&](Value value) -> Value {
          if (!condition)
            return value;
          auto integer = dyn_cast<IntegerType>(value.getType());
          if (!integer)
            return value;
          Value zero = hw::ConstantOp::create(builder, loc, integer, 0);
          return comb::MuxOp::create(builder, loc, condition, value, zero);
        };
        if (instanceOp.getNumResults() == 1)
          return bindResult(dest, gate(instanceOp.getResult(0)), Value());
        if (instanceOp.getNumResults() == 2)
          return bindResult(dest, gate(instanceOp.getResult(0)),
                            gate(instanceOp.getResult(1)));
        return op->emitError()
               << "HDL lowering: instance with " << instanceOp.getNumResults()
               << " outputs is not supported";
      }
    }

    // `Logic[W]` values are lowered as a (value, xz-mask) pair of `comb`
    // nets. Binary calls take `(lhs, rhs, out-ptr)`, `mux_logic` takes
    // `(cond, a, b, out-ptr)`, and `__invert__` takes `(src, out-ptr)`.
    if (callee.contains("Logic::") || callee.contains("mux_logic")) {
      auto storeResult = [&](Value dest, LogicValue value) -> LogicalResult {
        if (!value)
          return failure();
        if (storeLoopCarriedLogic(dest, value, condition))
          return success();
        if (auto field = fieldPtrs.find(dest);
            field != fieldPtrs.end() &&
            field->second < fieldIsLogic.size() &&
            fieldIsLogic[field->second]) {
          return storeLogicField(field->second, value, condition);
        }
        logicValues[dest] = value;
        if (dest == resultPtr)
          recordReturn(value.val, value.xz);
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

    // `Packed[T, N]` is a single flattened payload value. Copies and moves
    // are identities at the CIRCT boundary; an integer constructor becomes a
    // packed constant.
    if (callee.contains("Packed::")) {
      if (callee.contains("::__deinit__") || callee.contains("::__del__"))
        return success();
      bool logicPacked = isLogicType(getCallTypeParam(op, 0));
      auto resize = [&](Value value, unsigned width) -> Value {
        unsigned valueWidth = value.getType().getIntOrFloatBitWidth();
        if (valueWidth == width)
          return value;
        if (valueWidth < width) {
          Value zeros = hw::ConstantOp::create(
              builder, loc, llvm::APInt(width - valueWidth, 0));
          return comb::ConcatOp::create(builder, loc,
                                        ArrayRef<Value>{zeros, value});
        }
        return comb::ExtractOp::create(builder, loc, value, 0, width);
      };

      if (callee.contains("__init__") && callee.contains("::SIMD") &&
          !callee.contains("__init__(move:")) {
        unsigned width = getCallPackedWidth(op, &bindings);
        Operation *valueOp = op->getOperand(0).getDefiningOp();
        auto value =
            valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
        if (!width || !value)
          return op->emitError()
                 << "HDL lowering: unsupported Packed constructor";
        Value constant = hw::ConstantOp::create(
            builder, loc, value->zextOrTrunc(width));
        Value dest = op->getOperand(1);
        if (logicPacked) {
          Value xz = hw::ConstantOp::create(
              builder, loc, llvm::APInt(width, 0));
          logicValues[dest] = {constant, xz};
          if (dest == resultPtr)
            recordReturn(constant, xz);
        } else {
          values[dest] = constant;
          if (dest == resultPtr)
            recordReturn(constant);
        }
        return success();
      }

      if (callee.contains("__getitem__") && op->getNumOperands() == 3) {
        unsigned packedWidth = getCallPackedWidth(op, &bindings);
        if (!packedWidth)
          return op->emitError()
                 << "HDL lowering: unsupported Packed element access";
        unsigned laneWidth = getHdlWidth(getCallTypeParam(op, 0), &bindings);
        Value index = getValue(op->getOperand(1));
        if (!index)
          return op->emitError()
                 << "HDL lowering: Packed element operand was not lowered";
        Value shift = resize(index, packedWidth);
        Value laneWidthValue = hw::ConstantOp::create(
            builder, loc, llvm::APInt(packedWidth, laneWidth));
        Value offset =
            comb::MulOp::create(builder, loc, shift, laneWidthValue);
        Value dest = op->getOperand(2);

        if (logicPacked) {
          LogicValue packed = getLogicValue(op->getOperand(0));
          if (!packed)
            return op->emitError()
                   << "HDL lowering: Packed operand was not lowered";
          auto extractLane = [&](Value word) -> Value {
            Value shifted = comb::ShrUOp::create(builder, loc, word, offset);
            return comb::ExtractOp::create(builder, loc, shifted, 0,
                                           laneWidth);
          };
          LogicValue lane{extractLane(packed.val), extractLane(packed.xz)};
          logicValues[dest] = lane;
          if (dest == resultPtr)
            recordReturn(lane.val, lane.xz);
          return success();
        }

        Value packed = getValue(op->getOperand(0));
        if (!packed)
          return op->emitError()
                 << "HDL lowering: Packed operand was not lowered";
        Value shifted = comb::ShrUOp::create(builder, loc, packed, offset);
        Value lane = comb::ExtractOp::create(builder, loc, shifted, 0,
                                             laneWidth);
        values[dest] = lane;
        if (dest == resultPtr)
          recordReturn(lane);
        return success();
      }

      if (callee.contains("__setitem__") && op->getNumOperands() == 3) {
        unsigned packedWidth = getCallPackedWidth(op, &bindings);
        if (!packedWidth)
          return op->emitError()
                 << "HDL lowering: unsupported Packed element access";
        unsigned laneWidth = getHdlWidth(getCallTypeParam(op, 0), &bindings);
        Value index = getValue(op->getOperand(1));
        if (!index)
          return op->emitError()
                 << "HDL lowering: Packed element operand was not lowered";
        Value shift = resize(index, packedWidth);
        Value laneWidthValue = hw::ConstantOp::create(
            builder, loc, llvm::APInt(packedWidth, laneWidth));
        Value offset =
            comb::MulOp::create(builder, loc, shift, laneWidthValue);
        llvm::APInt laneMask = llvm::APInt::getLowBitsSet(packedWidth,
                                                          laneWidth);
        Value mask = hw::ConstantOp::create(builder, loc, laneMask);
        Value shiftedMask = comb::ShlOp::create(builder, loc, mask, offset);

        auto insertLane = [&](Value word, Value lane) -> Value {
          Value wide = resize(lane, packedWidth);
          Value shiftedValue =
              comb::ShlOp::create(builder, loc, wide, offset);
          Value cleared =
              comb::AndOp::create(builder, loc, word, bitNot(shiftedMask));
          return comb::OrOp::create(builder, loc, cleared, shiftedValue);
        };

        Value self = op->getOperand(0);
        if (logicPacked) {
          LogicValue packed = getLogicValue(self);
          LogicValue value = getLogicValue(op->getOperand(2));
          if (!packed || !value)
            return op->emitError()
                   << "HDL lowering: Packed element operand was not lowered";
          LogicValue updated{insertLane(packed.val, value.val),
                             insertLane(packed.xz, value.xz)};
          if (storeLoopCarriedLogic(self, updated, condition))
            return success();
          values[self] = updated.val;
          logicValues[self] = updated;
          return success();
        }

        Value packed = getValue(self);
        Value value = getValue(op->getOperand(2));
        if (!packed || !value)
          return op->emitError()
                 << "HDL lowering: Packed element operand was not lowered";
        Value updated = insertLane(packed, value);
        if (storeLoopCarried(self, updated, condition))
          return success();
        values[self] = updated;
        return success();
      }

      if (op->getNumOperands() == 2) {
        Value dest = op->getOperand(1);
        if (logicPacked) {
          LogicValue source = getLogicValue(op->getOperand(0));
          if (!source)
            return op->emitError()
                   << "HDL lowering: Packed operand was not lowered";
          if (storeLoopCarriedLogic(dest, source, condition))
            return success();
          logicValues[dest] = source;
          if (dest == resultPtr)
            recordReturn(source.val, source.xz);
        } else {
          Value source = getValue(op->getOperand(0));
          if (!source)
            return op->emitError()
                   << "HDL lowering: Packed operand was not lowered";
          if (storeLoopCarried(dest, source, condition))
            return success();
          values[dest] = source;
          if (dest == resultPtr)
            recordReturn(source);
        }
        return success();
      }
      return op->emitError() << "HDL lowering: unsupported Packed call '"
                             << callee << "'";
    }

    // `Array[T, N]` used as a payload behaves like `Packed`: one flat value.
    // Copies, moves, and a packed-integer constructor only move the value.
    if (callee.contains("Array::") && !callee.contains("__getitem") &&
        !callee.contains("__setitem") &&
        (callee.contains("Array::copy") || callee.contains("Array::__init__")) &&
        op->getNumOperands() == 2) {
      Value dest = op->getOperand(1);
      bool storageDest = false;
      if (auto field = fieldPtrs.find(dest); field != fieldPtrs.end())
        storageDest = field->second < fieldIsArrayStorage.size() &&
                      fieldIsArrayStorage[field->second];
      if (!storageDest) {
        Type elemType = getCallTypeParam(op, 0);
        auto depth = getCallIntParam(op, 1, &bindings);
        unsigned laneWidth = getHdlWidth(elemType, &bindings);
        bool logicArray = elemType && isLogicType(elemType);
        auto writeValue = [&](Value value, Value xz) -> LogicalResult {
          if (xz && storeLoopCarriedLogic(dest, {value, xz}, condition))
            return success();
          if (!xz && storeLoopCarried(dest, value, condition))
            return success();
          if (auto field = fieldPtrs.find(dest); field != fieldPtrs.end()) {
            if (xz)
              return storeLogicField(field->second, {value, xz}, condition);
            return storeField(field->second, value, condition);
          }
          if (xz)
            logicValues[dest] = {value, xz};
          values[dest] = value;
          if (dest == resultPtr) {
            if (xz)
              recordReturn(value, xz);
            else
              recordReturn(value);
          }
          return success();
        };
        if (callee.contains("Bits::__init__"))
          return success();
        if (callee.contains("__init__") && !callee.contains("move:")) {
          if (!laneWidth || !depth)
            return op->emitError()
                   << "HDL lowering: unsupported Array constructor";
          Operation *valueOp = op->getOperand(0).getDefiningOp();
          auto constant =
              valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
          if (!constant)
            return op->emitError()
                   << "HDL lowering: Array constructor argument must be a "
                      "constant";
          unsigned total = laneWidth * depth->getZExtValue();
          Value packed = hw::ConstantOp::create(
              builder, loc, constant->zextOrTrunc(total));
          return writeValue(packed, Value());
        }
        if (logicArray) {
          LogicValue source = getLogicValue(op->getOperand(0));
          if (!source)
            return op->emitError()
                   << "HDL lowering: Array operand was not lowered";
          return writeValue(source.val, source.xz);
        }
        Value source = getValue(op->getOperand(0));
        if (!source)
          return op->emitError()
                 << "HDL lowering: Array operand was not lowered";
        return writeValue(source, Value());
      }
    }

    // `q.next(n) <= v`: the `Reg::next` delay overload recorded a target;
    // `NextTarget::__le__` performs the delayed update.
    if (callee.contains("NextTarget::__le__")) {
      if (op->getNumOperands() != 2)
        return op->emitError()
               << "HDL lowering: unexpected NextTarget assignment";
      auto target = delayedTargets.find(op->getOperand(0));
      if (target == delayedTargets.end())
        return op->emitError()
               << "HDL lowering: unknown delayed-next target";
      unsigned field = target->second.field;
      if (target->second.isArrayElement) {
        if (target->second.delay > 1)
          return op->emitError()
                 << "HDL lowering: delayed next on array elements is not "
                    "supported yet";
        bool isLogic = arrayIsLogic.lookup(field);
        if (isLogic) {
          LogicValue value = getLogicValue(op->getOperand(1));
          if (!value)
            return op->emitError()
                   << "HDL lowering: delayed-next value was not lowered";
          return arrayWrite(field, target->second.elementIndex, value.val,
                            value.xz, true, Value(), condition);
        }
        Value value = getValue(op->getOperand(1));
        if (!value)
          return op->emitError()
                 << "HDL lowering: delayed-next value was not lowered";
        return arrayWrite(field, target->second.elementIndex, value, Value(),
                          false, Value(), condition);
      }
      if (field < fieldIsLogic.size() && fieldIsLogic[field]) {
        LogicValue value = getLogicValue(op->getOperand(1));
        if (!value)
          return op->emitError()
                 << "HDL lowering: delayed-next value was not lowered";
        return delayedLogicWrite(field, target->second.delay, value,
                                 condition);
      }
      Value value = getValue(op->getOperand(1));
      if (!value)
        return op->emitError()
               << "HDL lowering: delayed-next value was not lowered";
      return delayedWrite(field, target->second.delay, value, condition);
    }

    // `Reg[T, style]` is a typed state field. `.next` is the clocked update
    // and `.get` reads the current value; `T` may be 2-state `Bits[W]` or
    // 4-state `Logic[W]`.
    if (callee.contains("Reg::")) {
      if (callee.contains("::__deinit__") || callee.contains("::__del__"))
        return success();

      // Record the delayed-update target returned by `q.next(n)`.
      if (callee.contains("::next") && op->getNumOperands() == 3 &&
          callee.contains("::SIMD")) {
        unsigned field = 0;
        Value elementIndex;
        bool isArrayElement = false;
        if (auto element = arrayElements.find(op->getOperand(0));
            element != arrayElements.end()) {
          field = element->second.field;
          elementIndex = element->second.index;
          isArrayElement = true;
        } else if (auto fieldPtr = fieldPtrs.find(op->getOperand(0));
                   fieldPtr != fieldPtrs.end()) {
          field = fieldPtr->second;
        } else {
          return op->emitError()
                 << "HDL lowering: delayed next on a non-field value";
        }
        auto delay = getConstantInt(op->getOperand(1).getDefiningOp(),
                                    &bindings);
        if (!delay)
          return op->emitError()
                 << "HDL lowering: delayed next requires a constant delay";
        delayedTargets[op->getOperand(2)] = {
            field, static_cast<unsigned>(delay->getZExtValue()), elementIndex,
            isArrayElement};
        return success();
      }

      // `q.past(n)`: a read-only delay chain fed by the field's current value.
      if (callee.contains("::past") && op->getNumOperands() == 3) {
        auto field = fieldPtrs.find(op->getOperand(0));
        if (field == fieldPtrs.end())
          return op->emitError()
                 << "HDL lowering: past() on a non-field value";
        auto delay = getConstantInt(op->getOperand(1).getDefiningOp(),
                                    &bindings);
        if (!delay)
          return op->emitError()
                 << "HDL lowering: past() requires a constant delay";
        unsigned delayValue = static_cast<unsigned>(delay->getZExtValue());
        Value dest = op->getOperand(2);
        if (fieldIsLogic[field->second]) {
          LogicValue result = pastLogicValue(field->second, delayValue);
          if (!result)
            return op->emitError()
                   << "HDL lowering: unsupported Logic past() state";
          logicValues[dest] = result;
          if (dest == resultPtr)
            recordReturn(result.val, result.xz);
          return success();
        }
        Value result = pastValue(field->second, delayValue);
        if (!result)
          return op->emitError()
                 << "HDL lowering: unsupported past() state";
        values[dest] = result;
        if (dest == resultPtr)
          recordReturn(result);
        return success();
      }

      auto storeLogicResult = [&](Value dest,
                                  LogicValue value) -> LogicalResult {
        if (!value)
          return failure();
        if (auto field = fieldPtrs.find(dest);
            field != fieldPtrs.end() &&
            field->second < fieldIsLogic.size() &&
            fieldIsLogic[field->second])
          return storeLogicField(field->second, value, condition);
        logicValues[dest] = value;
        if (dest == resultPtr)
          recordReturn(value.val, value.xz);
        return success();
      };

      auto arrayElement = [&](Value ptr) -> ArrayElementAccess * {
        auto it = arrayElements.find(ptr);
        return it == arrayElements.end() ? nullptr : &it->second;
      };
      auto storeElement = [&](ArrayElementAccess &elem, Value data,
                              Value dataXz,
                              bool isLogic) -> LogicalResult {
        return arrayWrite(elem.field, elem.index, data, dataXz, isLogic,
                          Value(), condition);
      };
      auto loadElement = [&](ArrayElementAccess &elem,
                             Value dest) -> LogicalResult {
        bool isLogic = arrayIsLogic.lookup(elem.field);
        Value xz;
        Value value = arrayRead(elem.field, elem.index, isLogic, xz);
        if (!value)
          return op->emitError() << "HDL lowering: empty array storage";
        if (isLogic)
          return storeLogicResult(dest, {value, xz});
        values[dest] = value;
        if (dest == resultPtr)
          recordReturn(value);
        return success();
      };

      // A `Reg` call whose receiver is an array element: `mem[i].next(v)` or
      // `mem[i].get()`. The element pointer was recorded by
      // `Array::__getitem__`; lower it against the array's storage slots.
      if (auto *elem = arrayElement(op->getOperand(0))) {
        bool isLogic = arrayIsLogic.lookup(elem->field);
        if (callee.contains("::next") && op->getNumOperands() == 2) {
          if (isLogic) {
            LogicValue value = getLogicValue(op->getOperand(1));
            if (!value)
              return op->emitError()
                     << "HDL lowering: array element operand was not lowered";
            return storeElement(*elem, value.val, value.xz, true);
          }
          Value value = getValue(op->getOperand(1));
          if (!value)
            return op->emitError()
                   << "HDL lowering: array element operand was not lowered";
          return storeElement(*elem, value, Value(), false);
        }
        if (op->getNumOperands() == 2)
          return loadElement(*elem, op->getOperand(1));
      }

      // A `Reg` construction/move whose destination is an array element:
      // `mem[i] = Reg(...)`.
      if (op->getNumOperands() == 2) {
        if (auto *elem = arrayElement(op->getOperand(1))) {
          bool isLogic = arrayIsLogic.lookup(elem->field);
          if (callee.contains("__init__") &&
              callee.contains("::SIMD") &&
              !callee.contains("__init__(move:")) {
            unsigned width = fieldArrayWidths[elem->field];
            Operation *valueOp = op->getOperand(0).getDefiningOp();
            auto value =
                valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
            if (!width || !value)
              return op->emitError()
                     << "HDL lowering: unsupported array element constructor";
            Value constant = hw::ConstantOp::create(
                builder, loc, value->zextOrTrunc(width));
            if (isLogic) {
              Value xz = hw::ConstantOp::create(
                  builder, loc, llvm::APInt(width, 0));
              return storeElement(*elem, constant, xz, true);
            }
            return storeElement(*elem, constant, Value(), false);
          }
          if (isLogic) {
            LogicValue value = getLogicValue(op->getOperand(0));
            if (!value)
              return op->emitError()
                     << "HDL lowering: array element operand was not lowered";
            return storeElement(*elem, value.val, value.xz, true);
          }
          Value value = getValue(op->getOperand(0));
          if (!value)
            return op->emitError()
                   << "HDL lowering: array element operand was not lowered";
          return storeElement(*elem, value, Value(), false);
        }
      }

      if (callee.contains("__init__") && callee.contains("::SIMD") &&
          !callee.contains("__init__(move:")) {
        Value dest = op->getOperand(1);
        auto field = fieldPtrs.find(dest);
        bool isLogic = field != fieldPtrs.end() &&
                       field->second < fieldIsLogic.size() &&
                       fieldIsLogic[field->second];
        unsigned width = field != fieldPtrs.end() ? fieldWidths[field->second]
                                                  : getHdlWidth(
                                                        getCallTypeParam(op, 0),
                                                        &bindings);
        Operation *valueOp = op->getOperand(0).getDefiningOp();
        auto value =
            valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
        if (!width || !value)
          return op->emitError()
                 << "HDL lowering: unsupported Reg constructor";
        Value constant = hw::ConstantOp::create(
            builder, loc, value->zextOrTrunc(width));
        if (isLogic) {
          Value xz = hw::ConstantOp::create(
              builder, loc, llvm::APInt(width, 0));
          return storeLogicResult(dest, {constant, xz});
        }
        if (auto fieldPtr = fieldPtrs.find(dest);
            fieldPtr != fieldPtrs.end())
          resetValues[fieldPtr->second] = *value;
        else
          values[dest] = constant;
        return success();
      }

      if (callee.contains("::next") && op->getNumOperands() == 2) {
        auto field = fieldPtrs.find(op->getOperand(0));
        if (field == fieldPtrs.end())
          return op->emitError()
                 << "HDL lowering: Reg::next on a non-field value";
        if (field->second < fieldIsLogic.size() &&
            fieldIsLogic[field->second]) {
          LogicValue value = getLogicValue(op->getOperand(1));
          if (!value)
            return op->emitError()
                   << "HDL lowering: Reg::next operand was not lowered";
          return storeLogicField(field->second, value, condition);
        }
        Value value = getValue(op->getOperand(1));
        if (!value)
          return op->emitError()
                 << "HDL lowering: Reg::next operand was not lowered";
        return storeField(field->second, value, condition);
      }

      if (op->getNumOperands() == 2) {
        Value dest = op->getOperand(1);
        if (LogicValue source = getLogicValue(op->getOperand(0)))
          return storeLogicResult(dest, source);
        Value source = getValue(op->getOperand(0));
        if (!source)
          return op->emitError()
                 << "HDL lowering: Reg operand was not lowered";
        if (dest == resultPtr)
          recordReturn(source);
        else if (auto field = fieldPtrs.find(dest); field != fieldPtrs.end())
          return storeField(field->second, source, condition);
        else
          values[dest] = source;
        return success();
      }

      return op->emitError() << "HDL lowering: unsupported Reg call '"
                             << callee << "'";
    }

    // A `Wire[W]` field is a combinational SSA net: assignments update the
    // field's current definition and reads copy it out.
    if (callee.contains("Wire::")) {
      if (callee.contains("::__deinit__") || callee.contains("::__del__"))
        return success();
      if (callee.contains("__init__") && callee.contains("::SIMD")) {
        unsigned width = getCallParamWidth(op, &bindings);
        Operation *valueOp = op->getOperand(0).getDefiningOp();
        auto value =
            valueOp ? getConstantInt(valueOp, &bindings) : std::nullopt;
        if (!width || !value)
          return op->emitError()
                 << "HDL lowering: unsupported Wire constructor";
        Value constant = hw::ConstantOp::create(
            builder, loc, value->zextOrTrunc(width));
        Value dest = op->getOperand(1);
        if (auto field = fieldPtrs.find(dest);
            field != fieldPtrs.end() &&
            field->second < fieldIsWire.size() &&
            fieldIsWire[field->second])
          wireValues[field->second] = constant;
        else
          values[dest] = constant;
        if (dest == resultPtr)
          recordReturn(constant);
        return success();
      }
      if (op->getNumOperands() == 2) {
        Value source = getValue(op->getOperand(0));
        if (!source)
          return op->emitError()
                 << "HDL lowering: Wire operand was not lowered";
        Value dest = op->getOperand(1);
        if (auto field = fieldPtrs.find(dest);
            field != fieldPtrs.end() &&
            field->second < fieldIsWire.size() &&
            fieldIsWire[field->second])
          wireValues[field->second] = source;
        else
          values[dest] = source;
        if (dest == resultPtr)
          recordReturn(source);
        return success();
      }
      return op->emitError() << "HDL lowering: unsupported Wire call '"
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
          recordReturn(result);
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
            recordReturn(constant);
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
            recordReturn(result);
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
          Value dest = resolveStructField(op->getOperand(1));
          if (storeLoopCarried(dest, source, condition))
            return success();
          if (isLoopCarriedSlot(dest))
            return op->emitError()
                   << "HDL lowering: unsupported loop-carried local type in a "
                      "runtime-bounded loop";
          if (dest == resultPtr) {
            recordReturn(source);
          } else if (auto field = fieldPtrs.find(dest);
                     field != fieldPtrs.end()) {
            return storeField(field->second, source, condition);
          } else {
            values[dest] = source;
          }
          return success();
        }
        if (callee.contains("Bits::copy")) {
          Value dest = resolveStructField(op->getOperand(1));
          if (storeLoopCarried(dest, source, condition))
            return success();
          if (isLoopCarriedSlot(dest))
            return op->emitError()
                   << "HDL lowering: unsupported loop-carried local type in a "
                      "runtime-bounded loop";
          if (dest == resultPtr)
            recordReturn(source);
          else if (auto field = fieldPtrs.find(dest);
                   field != fieldPtrs.end())
            return storeField(field->second, source, condition);
          else
            values[dest] = source;
          return success();
        }
      }
      return op->emitError() << "HDL lowering: unsupported Bits call '" << callee
                             << "'";
    }

    if ((callee.contains("::__bool__") || callee.contains("__mlir_bool__")) &&
        inLoopUnroll) {
      if (auto constant = resolveConstant(op->getOperand(0))) {
        intConstants[op->getResult(0)] =
            llvm::APInt(1, constant->isZero() ? 0 : 1);
        values.erase(op->getResult(0));
        return success();
      }
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

    // In-place SIMD increment, used by loop induction variables.
    if (callee.contains("SIMD::__iadd__") && op->getNumOperands() == 2) {
      Value dest = op->getOperand(0);
      if (loopCarriedRegs.count(dest)) {
        Value old = getValue(dest);
        Value increment = getValue(op->getOperand(1));
        if (!old || !increment)
          return op->emitError()
                 << "HDL lowering: in-place add operand was not lowered";
        Value sum = comb::AddOp::create(builder, loc, old, increment);
        storeLoopCarried(dest, sum, condition);
        return success();
      }
      if (inLoopUnroll) {
        if (auto current = resolveConstant(dest))
          if (auto increment = resolveConstant(op->getOperand(1))) {
            slotConstants[dest] = *current + *increment;
            values.erase(dest);
            intConstants.erase(op->getResult(0));
            return success();
          }
      }
      Value old = getValue(dest);
      Value increment = getValue(op->getOperand(1));
      if (!old || !increment)
        return op->emitError()
               << "HDL lowering: in-place add operand was not lowered";
      Value sum = comb::AddOp::create(builder, loc, old, increment);
      values[dest] = sum;
      if (auto field = fieldPtrs.find(dest); field != fieldPtrs.end())
        return storeField(field->second, sum, condition);
      slotConstants.erase(dest);
      return success();
    }

    // SIMD lane arithmetic from the primitive `UInt8`/`UInt16` DSL path.
    if (op->getNumOperands() == 2) {
      if (inLoopUnroll &&
          (callee.contains("SIMD::__lt__") || callee.contains("SIMD::__le__") ||
           callee.contains("SIMD::__eq__") || callee.contains("SIMD::__ne__"))) {
        if (auto lhsConstant = resolveConstant(op->getOperand(0)))
          if (auto rhsConstant = resolveConstant(op->getOperand(1))) {
            unsigned width =
                std::max(lhsConstant->getBitWidth(), rhsConstant->getBitWidth());
            llvm::APInt lhs = lhsConstant->zext(width);
            llvm::APInt rhs = rhsConstant->zext(width);
            bool result = false;
            if (callee.contains("SIMD::__lt__"))
              result = lhs.ult(rhs);
            else if (callee.contains("SIMD::__le__"))
              result = lhs.ule(rhs);
            else if (callee.contains("SIMD::__eq__"))
              result = lhs == rhs;
            else
              result = lhs != rhs;
            intConstants[op->getResult(0)] = llvm::APInt(1, result ? 1 : 0);
            values.erase(op->getResult(0));
            return success();
          }
      }
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

    // Constant `range(n)` loops are unrolled symbolically. The iterator
    // protocol is carried through stack slots without emitting hardware.
    if ((callee.contains("::range::range[") ||
         callee.contains("::_ZeroStartingRange::__iter__")) &&
        op->getNumOperands() == 1) {
      if (auto range = resolveRange(op->getOperand(0))) {
        rangeValues[op->getResult(0)] = *range;
        return success();
      }
      if (auto stop = resolveConstant(op->getOperand(0))) {
        rangeValues[op->getResult(0)] = {0, stop->getZExtValue(), Value()};
        return success();
      }
      Value bound = getValue(op->getOperand(0));
      if (!bound)
        return op->emitError()
               << "HDL lowering: loop range bound was not lowered";
      rangeValues[op->getResult(0)] = {0, 0, bound};
      return success();
    }
    if (callee.contains("::_ZeroStartingRange::__next__")) {
      auto range = resolveRange(op->getOperand(0));
      if (!range || op->getNumOperands() < 2)
        return op->emitError()
               << "HDL lowering: loop range iterator was not lowered";
      if (range->runtimeBound)
        return op->emitError()
               << "HDL lowering: runtime range is only supported in a "
                  "time-multiplexed loop";
      Value resultPtr = op->getOperand(op->getNumOperands() - 1);
      uint64_t &next = rangeNext[op->getOperand(0)];
      bool done = next >= range->stop;
      intConstants[op->getResult(0)] =
          llvm::APInt(1, done ? 1 : 0);
      values.erase(op->getResult(0));
      if (!done) {
        slotConstants[resultPtr] = llvm::APInt(64, next);
        values.erase(resultPtr);
        ++next;
      }
      return success();
    }

    StringRef callName = callee.split('(').first;
    if (callName.ends_with("::__init__") && !callName.contains("hdl::") &&
        !callName.contains("std::"))
      return emitStructConstructor(op, callee, condition, returnValue);

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
    if (!index || op->getNumOperands() != 1)
      return op->emitError()
             << "HDL lowering: unsupported struct field access";
    if (op->getOperand(0) != selfPtr) {
      // `self.child.<field>`: a direct access into a child instance. Record
      // it and bind a placeholder so lowering can finish; the diagnostic is
      // emitted once every process (and therefore every owning domain) is
      // known.
      Value base = op->getOperand(0);
      if (!instancePtrs.count(base))
        if (auto path = resolveStructFieldPath(base, index.getInt())) {
          structFieldPaths[op->getResult(0)] = *path;
          Value slot = getStructFieldSlot(op, path->root, path->path);
          structFieldAliases[op->getResult(0)] = slot;
          return success();
        }
      if (auto instance = instancePtrs.find(base);
          instance != instancePtrs.end()) {
        unsigned field = instance->second;
        bool childHasClock = false;
        if (Operation *childOp = findBuiltModule(fieldModuleNames[field]))
          for (hw::PortInfo port :
               cast<hw::HWModuleOp>(childOp).getPortList())
            if (port.dir == hw::ModulePort::Direction::Input &&
                isa<seq::ClockType>(port.type))
              childHasClock = true;
        if (!childHasClock)
          return op->emitError()
                 << "HDL lowering: child instance '" << fieldNames[field]
                 << "' has no directly accessible state; call a method "
                    "instead";
        childFieldAccesses[field].push_back(
            {static_cast<unsigned>(index.getInt()), currentMethod});
        values[op->getResult(0)] =
            hw::ConstantOp::create(builder, loc, llvm::APInt(1, 0));
        return success();
      }
      return op->emitError()
             << "HDL lowering: unsupported struct field access";
    }
    unsigned field = index.getInt();
    if (field < fieldIsInstance.size() && fieldIsInstance[field])
      instancePtrs[op->getResult(0)] = field;
    else
      fieldPtrs[op->getResult(0)] = field;
    return success();
  }

  if (name == "pop.store") {
    Value target = resolveStructField(op->getOperand(1));
    auto field = fieldPtrs.find(target);
    if (field == fieldPtrs.end()) {
      // Remember integer constants and ranges held in stack slots so an
      // unrolled loop can evaluate its control path. A materialized constant
      // would only be dead state, so leave it symbolic until a load needs it.
      if (auto range = resolveRange(op->getOperand(0))) {
        rangeValues[target] = *range;
        slotConstants.erase(target);
        values.erase(target);
        return success();
      }
      rangeValues.erase(target);
      if (auto constant = resolveConstant(op->getOperand(0))) {
        slotConstants[target] = *constant;
        values.erase(target);
        return success();
      }
      slotConstants.erase(target);
    }
    Value stored = getValue(op->getOperand(0));
    if (!stored)
      return op->emitError() << "HDL lowering: stored value was not lowered";
    if (field != fieldPtrs.end())
      return storeField(field->second, stored, condition);
    if (storeLoopCarried(target, stored, condition))
      return success();
    if (isLoopCarriedSlot(target))
      return op->emitError()
             << "HDL lowering: unsupported loop-carried local type in a "
                "runtime-bounded loop";
    values[target] = stored;
    return success();
  }

  if (name == "pop.load") {
    Value source = resolveStructField(op->getOperand(0));
    auto field = fieldPtrs.find(source);
    if (field == fieldPtrs.end()) {
      if (auto range = resolveRange(source)) {
        rangeValues[op->getResult(0)] = *range;
        values.erase(op->getResult(0));
        return success();
      }
      auto slot = slotConstants.find(source);
      if (slot != slotConstants.end()) {
        intConstants[op->getResult(0)] = slot->second;
        values.erase(op->getResult(0));
        return success();
      }
    }
    if (field != fieldPtrs.end()) {
      auto type = getHwType(op->getResult(0).getType());
      if (!type)
        return op->emitError() << "HDL lowering: unsupported state type";
      values[op->getResult(0)] = getOrCreateReg(field->second, type);
      return success();
    }
    if (auto logic = logicValues.find(source);
        logic != logicValues.end()) {
      logicValues[op->getResult(0)] = logic->second;
      return success();
    }
    Value stored = getValue(source);
    if (!stored)
      return op->emitError() << "HDL lowering: loaded value was not lowered";
    values[op->getResult(0)] = stored;
    return success();
  }

  // Track allocations so a runtime loop can tell its own temporaries from
  // locals that live across iterations.
  if (name == "pop.stack_allocation") {
    stackSlots.push_back(op->getResult(0));
    return success();
  }

  // Ignore lifetime/bookkeeping ops.
  if (name == "pop.stack_alloc.lifetime.start" ||
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
  for (Operation &op : block.getOperations()) {
    // A break/continue ends the current block; enclosing blocks check the
    // same flag at their next iteration.
    if (!loopStack.empty() && (loopStack.back().breakTaken ||
                               loopStack.back().continueTaken))
      break;
    loopFollowedByLoop = false;
    if (op.getName().getStringRef() == "hlcf.loop") {
      for (auto it = std::next(op.getIterator()); it != block.end(); ++it)
        if (it->getName().getStringRef() == "hlcf.loop") {
          loopFollowedByLoop = true;
          break;
        }
    }
    if (failed(emitOp(&op, condition, returnValue)))
      return failure();
    // A completed runtime loop yields a one-cycle pulse. Ops after it in the
    // same block only take effect on that pulse.
    if (pendingLoopDone) {
      // Post-loop ops depend on the loop's done pulse rather than on the
      // condition that started it. This also lets a second loop in the same
      // block use the pulse as its start handshake.
      condition = pendingLoopDone;
      currentStartPulse = pendingLoopDone;
      pendingLoopDone = Value();
    }
  }
  return success();
}

LogicalResult CirctModuleEmitter::emitDynamicLoop(Operation *loop,
                                                 Value condition,
                                                 Value &returnValue,
                                                 bool &handled) {
  handled = false;
  if (inDynamicLoop)
    return success(); // Nested runtime loops are not supported yet.
  if (loop->getNumRegions() != 1 || loop->getRegion(0).empty())
    return success();
  Block &block = loop->getRegion(0).front();

  // Recognize the canonical `while i < bound` shape: an in-place increment of
  // a stack slot, a compare against that load, and an `hlcf.if` whose one
  // region breaks out of the loop.
  Operation *increment = nullptr;
  Value slot;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "kgen.call" &&
        callCalleeName(&op).contains("SIMD::__iadd__") &&
        op.getNumOperands() == 2) {
      increment = &op;
      slot = op.getOperand(0);
      break;
    }
  if (!increment || !slot || fieldPtrs.count(slot))
    return success();

  Operation *load = nullptr;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "pop.load" && op.getOperand(0) == slot) {
      load = &op;
      break;
    }
  if (!load)
    return success();

  Operation *compare = nullptr;
  Value bound;
  for (Operation &op : block.getOperations()) {
    if (op.getName().getStringRef() != "kgen.call" || op.getNumOperands() != 2)
      continue;
    StringRef callee = callCalleeName(&op);
    if (!callee.contains("SIMD::__lt__") && !callee.contains("SIMD::__le__"))
      continue;
    if (op.getOperand(0) == load->getResult(0))
      bound = op.getOperand(1);
    else if (op.getOperand(1) == load->getResult(0))
      bound = op.getOperand(0);
    else
      continue;
    compare = &op;
    break;
  }
  if (!compare || !bound)
    return success();

  // A constant bound is unrolled instead.
  if (slotConstants.count(bound))
    return success();
  if (Operation *boundOp = bound.getDefiningOp())
    if (getConstantInt(boundOp, &bindings))
      return success();

  Operation *boolOp = nullptr;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "kgen.call" && op.getNumOperands() == 1 &&
        callCalleeName(&op).contains("__mlir_bool__") &&
        op.getOperand(0) == compare->getResult(0)) {
      boolOp = &op;
      break;
    }
  if (!boolOp)
    return success();

  Operation *loopIf = nullptr;
  bool breakInThen = false;
  for (Operation &op : block.getOperations()) {
    if (op.getName().getStringRef() != "hlcf.if" || op.getNumOperands() != 1 ||
        op.getOperand(0) != boolOp->getResult(0))
      continue;
    auto hasBreak = [](Region &region) {
      if (region.empty())
        return false;
      for (Operation &inner : region.front())
        if (inner.getName().getStringRef() == "hlcf.break")
          return true;
      return false;
    };
    bool thenBreak = hasBreak(op.getRegion(0));
    bool elseBreak = hasBreak(op.getRegion(1));
    if (thenBreak != elseBreak) {
      loopIf = &op;
      breakInThen = thenBreak;
      break;
    }
  }
  if (!loopIf)
    return success();

  handled = true;
  unsigned width = 64;
  if (auto type = getHwType(load->getResult(0).getType()))
    width = type.getIntOrFloatBitWidth();
  auto counterType = IntegerType::get(builder.getContext(), width);
  llvm::APInt zeroBits(width, 0);
  Value counter = createRegister(loopRegisterId++, counterType, zeroBits,
                                 zeroBits, resetStyle);
  slotConstants.erase(slot);
  rangeValues.erase(slot);
  values[slot] = counter;
  childLoopRan = false;
  childLoopLast = Value();
  dynamicBreakCond = Value();
  Value savedRelative = loopRelativeCondition;
  loopRelativeCondition = Value();
  bool sequenced = condition && condition == currentStartPulse;
  Value started;
  if (sequenced) {
    auto i1Type = builder.getI1Type();
    llvm::APInt zeroBit(1, 0);
    started = createRegister(loopRegisterId++, i1Type, zeroBit, zeroBit,
                             resetStyle);
  }

  auto setRegNext = [&](Value reg, Value next) -> LogicalResult {
    if (auto cr = reg.getDefiningOp<seq::CompRegOp>()) {
      cr->setOperand(0, next);
      return success();
    }
    if (auto fr = reg.getDefiningOp<seq::FirRegOp>()) {
      fr->setOperand(0, next);
      return success();
    }
    return failure();
  };
  SmallVector<Value> carried = collectLoopCarriedSlots(block, slot);
  Value running;
  if (!carried.empty()) {
    auto i1Type = builder.getI1Type();
    llvm::APInt zeroBit(1, 0);
    running = createRegister(loopRegisterId++, i1Type, zeroBit, zeroBit,
                             resetStyle);
    for (Value carriedSlot : carried) {
      if (LogicValue initial = getLogicValue(carriedSlot)) {
        unsigned carriedWidth =
            initial.val.getType().getIntOrFloatBitWidth();
        auto carriedType =
            IntegerType::get(builder.getContext(), carriedWidth);
        llvm::APInt zeros(carriedWidth, 0);
        Value valReg = createRegister(loopRegisterId++, carriedType, zeros,
                                      zeros, resetStyle);
        Value xzReg = createRegister(loopRegisterId++, carriedType, zeros,
                                     zeros, resetStyle);
        values[carriedSlot] = valReg;
        logicValues[carriedSlot] = {valReg, xzReg};
        slotConstants.erase(carriedSlot);
        rangeValues.erase(carriedSlot);
        loopCarriedLogicRegs[carriedSlot] = {valReg, xzReg};
        loopCarriedLogicNext[carriedSlot] = {valReg, xzReg};
        loopCarriedLogicInit[carriedSlot] = initial;
        if (loopFollowedByLoop && !sequence.active)
          sequence.logic.push_back(SequenceCarriedLogic{
              carriedSlot, valReg, Value(), initial.val, xzReg, Value(),
              initial.xz});
        continue;
      }
      Value initial = getValue(carriedSlot);
      if (!initial)
        return loop->emitError()
               << "HDL lowering: loop-carried local was not lowered";
      unsigned carriedWidth = initial.getType().getIntOrFloatBitWidth();
      auto carriedType =
          IntegerType::get(builder.getContext(), carriedWidth);
      llvm::APInt zeros(carriedWidth, 0);
      Value reg = createRegister(loopRegisterId++, carriedType, zeros, zeros,
                                 resetStyle);
      values[carriedSlot] = reg;
      slotConstants.erase(carriedSlot);
      rangeValues.erase(carriedSlot);
      loopCarriedRegs[carriedSlot] = reg;
      loopCarriedNext[carriedSlot] = reg;
      loopCarriedInit[carriedSlot] = initial;
      if (loopFollowedByLoop && !sequence.active)
        sequence.carried.push_back(
            SequenceCarried{carriedSlot, reg, Value(), initial});
    }
    loopRunning = running;
    if (loopFollowedByLoop && !sequence.active) {
      sequence.active = true;
      sequence.running = running;
      sequence.counter = counter;
    }
  }

  Value active;
  bool sawIf = false;
  Value &outerCondition = condition;
  dynamicLoopOuterSlots = stackSlots;
  inDynamicLoop = true;
  dynamicLoopSlot = slot;
  for (Operation &op : block.getOperations()) {
    if (&op == increment)
      continue; // The counter update replaces the in-place increment.
    if (&op == loopIf) {
      Value cond = getValue(op.getOperand(0));
      if (!cond)
        return op.emitError() << "HDL lowering: loop condition was not lowered";
      active = breakInThen ? bitNot(cond) : cond;
      if (running)
        active = comb::AndOp::create(builder, loc, running, active);
      if (started)
        active = comb::AndOp::create(builder, loc, started, active);
      Region &keep = breakInThen ? op.getRegion(1) : op.getRegion(0);
      Value inner =
          (outerCondition && !sequenced)
              ? comb::AndOp::create(builder, loc, outerCondition, active)
              : active;
      if (!keep.empty())
        if (failed(emitBlock(keep.front(), inner, returnValue)))
          return failure();
      sawIf = true;
      continue;
    }
    if (op.getName().getStringRef() == "hlcf.continue" || op.getName().getStringRef() == "hlcf.yield" ||
        op.getName().getStringRef() == "hlcf.break")
      continue;
    Value opCondition;
    if (!sawIf)
      opCondition = sequenced ? Value() : outerCondition;
    else if (sequenced)
      opCondition = active;
    else
      opCondition = outerCondition
                        ? comb::AndOp::create(builder, loc, outerCondition,
                                              active)
                        : active;
    if (failed(emitOp(&op, opCondition, returnValue)))
      return failure();
  }
  inDynamicLoop = false;
  dynamicLoopSlot = Value();
  dynamicLoopOuterSlots.clear();
  loopRelativeCondition = savedRelative;
  if (!sawIf)
    return loop->emitError()
           << "HDL lowering: runtime loop has no condition";
  if (running) {
    // Iterate the slot list, not the register maps, so emitted order does not
    // depend on DenseMap hashing.
    for (Value carriedSlot : carried) {
      if (auto it = loopCarriedLogicRegs.find(carriedSlot);
          it != loopCarriedLogicRegs.end()) {
        auto regs = it->second;
        LogicValue bodyNext = loopCarriedLogicNext[carriedSlot];
        LogicValue initial = loopCarriedLogicInit[carriedSlot];
        Value valMuxed =
            comb::MuxOp::create(builder, loc, running, bodyNext.val,
                                initial.val);
        Value xzMuxed = comb::MuxOp::create(builder, loc, running, bodyNext.xz,
                                            initial.xz);
        if (failed(setRegNext(regs.val, valMuxed)) ||
            failed(setRegNext(regs.xz, xzMuxed)))
          return loop->emitError()
                 << "HDL lowering: unsupported carried register form";
        if (sequence.active && loopFollowedByLoop) {
          for (auto &entry : sequence.logic)
            if (entry.slot == carriedSlot) {
              entry.valNext = valMuxed;
              entry.xzNext = xzMuxed;
            }
        }
        continue;
      }
      Value reg = loopCarriedRegs[carriedSlot];
      Value bodyNext = loopCarriedNext[carriedSlot];
      Value initial = loopCarriedInit[carriedSlot];
      Value muxed =
          comb::MuxOp::create(builder, loc, running, bodyNext, initial);
      if (failed(setRegNext(reg, muxed)))
        return loop->emitError()
               << "HDL lowering: unsupported carried register form";
      if (sequence.active && loopFollowedByLoop) {
        for (auto &entry : sequence.carried)
          if (entry.slot == carriedSlot)
            entry.next = muxed;
      }
    }
    for (auto &[slot, reg] : loopCarriedRegs)
      values[slot] = reg;
    for (auto &[slot, regs] : loopCarriedLogicRegs) {
      values[slot] = regs.val;
      logicValues[slot] = regs;
    }
    loopCarriedRegs.clear();
    loopCarriedNext.clear();
    loopCarriedInit.clear();
    loopCarriedLogicRegs.clear();
    loopCarriedLogicNext.clear();
    loopCarriedLogicInit.clear();
  }

  Value one = hw::ConstantOp::create(builder, loc, counterType, 1);
  Value incremented = comb::AddOp::create(builder, loc, counter, one);
  Value zero = hw::ConstantOp::create(builder, loc, counterType, 0);
  Value boundValue = getValue(bound);
  if (!boundValue)
    return loop->emitError() << "HDL lowering: loop bound was not lowered";
  unsigned boundWidth = boundValue.getType().getIntOrFloatBitWidth();
  if (boundWidth > width)
    boundValue = comb::ExtractOp::create(builder, loc, boundValue, 0, width);
  else if (boundWidth < width) {
    Value zeros = hw::ConstantOp::create(
        builder, loc, llvm::APInt(width - boundWidth, 0));
    boundValue = comb::ConcatOp::create(
        builder, loc, ArrayRef<Value>{zeros, boundValue});
  }
  // A loop inside a conditional branch only runs while that branch is
  // active. Gate its control (counter, break, done) by the branch condition.
  Value loopEnabled = active;
  if (!sequenced && outerCondition)
    loopEnabled =
        comb::AndOp::create(builder, loc, outerCondition, active);
  Value breakNow =
      dynamicBreakCond
          ? comb::AndOp::create(builder, loc, loopEnabled, dynamicBreakCond)
          : Value();
  Value atEnd = comb::ICmpOp::create(
      builder, loc, comb::ICmpPredicate::eq, incremented, boundValue);
  Value inRangeLast = comb::AndOp::create(
      builder, loc, childLoopRan ? childLoopLast : loopEnabled, atEnd);
  Value last = breakNow ? comb::OrOp::create(builder, loc, inRangeLast, breakNow)
                        : inRangeLast;
  Value step =
      breakNow ? comb::MuxOp::create(builder, loc, breakNow, boundValue,
                                     incremented)
               : incremented;
  Value idle = loopFollowedByLoop ? counter : zero;
  Value next =
      childLoopRan
          ? comb::MuxOp::create(
                builder, loc, childLoopLast,
                comb::MuxOp::create(builder, loc, last, zero, incremented),
                breakNow ? zero : counter)
          : comb::MuxOp::create(builder, loc, loopEnabled, step, idle);
  if (auto reg = counter.getDefiningOp<seq::CompRegOp>())
    reg->setOperand(0, next);
  else if (auto reg = counter.getDefiningOp<seq::FirRegOp>())
    reg->setOperand(0, next);
  else
    return loop->emitError() << "HDL lowering: unsupported loop counter form";
  if (sequence.active && loopFollowedByLoop)
    sequence.counterNext = next;
  if (started) {
    Value trueValue = getConstant(true);
    Value falseValue = getConstant(false);
    Value hold = comb::MuxOp::create(builder, loc, last, falseValue, started);
    Value next = comb::MuxOp::create(builder, loc, condition, trueValue, hold);
    if (failed(setRegNext(started, next)))
      return loop->emitError()
             << "HDL lowering: unsupported sequenced start form";
  }
  auto i1Type = builder.getI1Type();
  llvm::APInt oneBit(1, 1);
  llvm::APInt zeroBit(1, 0);
  Value done = createRegister(loopRegisterId++, i1Type, zeroBit, zeroBit,
                              resetStyle);
  if (auto reg = done.getDefiningOp<seq::CompRegOp>())
    reg->setOperand(0, last);
  else if (auto reg = done.getDefiningOp<seq::FirRegOp>())
    reg->setOperand(0, last);
  if (running) {

    Value notLast = bitNot(last);
    Value runningBase =
        comb::MuxOp::create(builder, loc, running, notLast,
                            getConstant(true));
    Value runningNext =
        loopFollowedByLoop
            ? getConstant(true)
            : (started ? comb::MuxOp::create(builder, loc, started,
                                             runningBase, getConstant(false))
                       : runningBase);
    if (!sequenced && condition)
      runningNext = comb::MuxOp::create(builder, loc, condition, runningNext,
                                        getConstant(false));
    if (failed(setRegNext(running, runningNext)))
      return loop->emitError()
             << "HDL lowering: unsupported running register form";
    if (sequence.active && loopFollowedByLoop)
      sequence.runningNext = runningNext;
    loopCarriedRegs.clear();
    loopCarriedNext.clear();
    loopCarriedInit.clear();
    loopCarriedLogicRegs.clear();
    loopCarriedLogicNext.clear();
    loopCarriedLogicInit.clear();
    loopRunning = Value();
  }
  if (sequence.active && !loopFollowedByLoop) {
    auto patchNext = [&](Value reg, Value oldNext, Value restartValue) {
      if (!reg)
        return;
      Value patched =
          comb::MuxOp::create(builder, loc, done, restartValue, oldNext);
      if (auto cr = reg.getDefiningOp<seq::CompRegOp>())
        cr->setOperand(0, patched);
      else if (auto fr = reg.getDefiningOp<seq::FirRegOp>())
        fr->setOperand(0, patched);
    };
    patchNext(sequence.running, sequence.runningNext, getConstant(false));
    auto counterType = sequence.counter.getType();
    patchNext(sequence.counter, sequence.counterNext,
              hw::ConstantOp::create(
                  builder, loc,
                  llvm::APInt(counterType.getIntOrFloatBitWidth(), 0)));
    for (auto &entry : sequence.carried)
      patchNext(entry.reg, entry.next, entry.init);
    for (auto &entry : sequence.logic) {
      patchNext(entry.valReg, entry.valNext, entry.valInit);
      patchNext(entry.xzReg, entry.xzNext, entry.xzInit);
    }
    sequence = SequenceState();
  }
  if (loopStack.empty())
    pendingLoopDone = done;
  return success();
}

LogicalResult CirctModuleEmitter::emitRuntimeRangeLoop(
    Operation *loop, Value condition, Value &returnValue, bool &handled) {
  handled = false;
  if (inDynamicLoop)
    return success();
  if (loop->getNumRegions() != 1 || loop->getRegion(0).empty())
    return success();
  Block &block = loop->getRegion(0).front();

  Operation *nextOp = nullptr;
  Value iterator;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "kgen.call" &&
        callCalleeName(&op).contains("::_ZeroStartingRange::__next__")) {
      nextOp = &op;
      iterator = op.getOperand(0);
      break;
    }
  if (!nextOp || nextOp->getNumOperands() < 2)
    return success();
  auto range = resolveRange(iterator);
  if (!range || !range->runtimeBound)
    return success();
  Value bound = range->runtimeBound;

  // When the body reads the loop variable, `__next__`'s by-ref result is
  // loaded and stored into a slot. A body that ignores the variable (for
  // example `for _ in range(n)`) has no such store; the counter is then only
  // internal state.
  Value byrefResult = nextOp->getOperand(nextOp->getNumOperands() - 1);
  Operation *indLoad = nullptr;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "pop.load" &&
        op.getOperand(0) == byrefResult) {
      indLoad = &op;
      break;
    }
  Operation *indStore = nullptr;
  Value slot;
  if (indLoad)
    for (Operation &op : block.getOperations())
      if (op.getName().getStringRef() == "pop.store" &&
          op.getNumOperands() == 2 &&
          op.getOperand(0) == indLoad->getResult(0) &&
          !fieldPtrs.count(op.getOperand(1))) {
        indStore = &op;
        slot = op.getOperand(1);
        break;
      }

  Operation *loopIf = nullptr;
  for (Operation &op : block.getOperations()) {
    if (op.getName().getStringRef() != "hlcf.if" || op.getNumOperands() != 1 ||
        op.getOperand(0) != nextOp->getResult(0))
      continue;
    auto hasBreak = [](Region &region) {
      if (region.empty())
        return false;
      for (Operation &inner : region.front())
        if (inner.getName().getStringRef() == "hlcf.break")
          return true;
      return false;
    };
    if (hasBreak(op.getRegion(0)) != hasBreak(op.getRegion(1))) {
      loopIf = &op;
      break;
    }
  }
  if (!loopIf)
    return success();

  handled = true;
  unsigned width = 64;
  if (auto intType = dyn_cast<IntegerType>(bound.getType()))
    width = intType.getWidth();
  auto counterType = IntegerType::get(builder.getContext(), width);
  Value boundValue = bound;
  unsigned boundWidth = bound.getType().getIntOrFloatBitWidth();
  if (boundWidth > width) {
    boundValue = comb::ExtractOp::create(builder, loc, bound, 0, width);
  } else if (boundWidth < width) {
    Value zeros = hw::ConstantOp::create(
        builder, loc, llvm::APInt(width - boundWidth, 0));
    boundValue = comb::ConcatOp::create(
        builder, loc, ArrayRef<Value>{zeros, bound});
  }
  llvm::APInt zeroBits(width, 0);
  Value counter = createRegister(loopRegisterId++, counterType, zeroBits,
                                 zeroBits, resetStyle);
  if (slot) {
    slotConstants.erase(slot);
    rangeValues.erase(slot);
    values[slot] = counter;
  }
  childLoopRan = false;
  childLoopLast = Value();
  dynamicBreakCond = Value();
  Value savedRelative = loopRelativeCondition;
  loopRelativeCondition = Value();
  bool sequenced = condition && condition == currentStartPulse;
  Value started;
  if (sequenced) {
    auto i1Type = builder.getI1Type();
    llvm::APInt zeroBit(1, 0);
    started = createRegister(loopRegisterId++, i1Type, zeroBit, zeroBit,
                             resetStyle);
  }

  auto setRegNext = [&](Value reg, Value next) -> LogicalResult {
    if (auto cr = reg.getDefiningOp<seq::CompRegOp>()) {
      cr->setOperand(0, next);
      return success();
    }
    if (auto fr = reg.getDefiningOp<seq::FirRegOp>()) {
      fr->setOperand(0, next);
      return success();
    }
    return failure();
  };
  SmallVector<Value> carried = collectLoopCarriedSlots(block, slot);
  Value running;
  if (!carried.empty()) {
    auto i1Type = builder.getI1Type();
    llvm::APInt zeroBit(1, 0);
    running = createRegister(loopRegisterId++, i1Type, zeroBit, zeroBit,
                             resetStyle);
    for (Value carriedSlot : carried) {
      if (LogicValue initial = getLogicValue(carriedSlot)) {
        unsigned carriedWidth =
            initial.val.getType().getIntOrFloatBitWidth();
        auto carriedType =
            IntegerType::get(builder.getContext(), carriedWidth);
        llvm::APInt zeros(carriedWidth, 0);
        Value valReg = createRegister(loopRegisterId++, carriedType, zeros,
                                      zeros, resetStyle);
        Value xzReg = createRegister(loopRegisterId++, carriedType, zeros,
                                     zeros, resetStyle);
        values[carriedSlot] = valReg;
        logicValues[carriedSlot] = {valReg, xzReg};
        slotConstants.erase(carriedSlot);
        rangeValues.erase(carriedSlot);
        loopCarriedLogicRegs[carriedSlot] = {valReg, xzReg};
        loopCarriedLogicNext[carriedSlot] = {valReg, xzReg};
        loopCarriedLogicInit[carriedSlot] = initial;
        if (loopFollowedByLoop && !sequence.active)
          sequence.logic.push_back(SequenceCarriedLogic{
              carriedSlot, valReg, Value(), initial.val, xzReg, Value(),
              initial.xz});
        continue;
      }
      Value initial = getValue(carriedSlot);
      if (!initial)
        return loop->emitError()
               << "HDL lowering: loop-carried local was not lowered";
      unsigned carriedWidth = initial.getType().getIntOrFloatBitWidth();
      auto carriedType =
          IntegerType::get(builder.getContext(), carriedWidth);
      llvm::APInt zeros(carriedWidth, 0);
      Value reg = createRegister(loopRegisterId++, carriedType, zeros, zeros,
                                 resetStyle);
      values[carriedSlot] = reg;
      slotConstants.erase(carriedSlot);
      rangeValues.erase(carriedSlot);
      loopCarriedRegs[carriedSlot] = reg;
      loopCarriedNext[carriedSlot] = reg;
      loopCarriedInit[carriedSlot] = initial;
      if (loopFollowedByLoop && !sequence.active)
        sequence.carried.push_back(
            SequenceCarried{carriedSlot, reg, Value(), initial});
    }
    loopRunning = running;
    if (loopFollowedByLoop && !sequence.active) {
      sequence.active = true;
      sequence.running = running;
      sequence.counter = counter;
    }
  }

  Value active = comb::ICmpOp::create(
      builder, loc, comb::ICmpPredicate::ult, counter, boundValue);
  if (running)
    active = comb::AndOp::create(builder, loc, running, active);
  if (started)
    active = comb::AndOp::create(builder, loc, started, active);

  SmallVector<Operation *> skipOps{nextOp, loopIf};
  if (indLoad)
    skipOps.push_back(indLoad);
  if (indStore)
    skipOps.push_back(indStore);
  inDynamicLoop = true;
  dynamicLoopSlot = slot;
  dynamicLoopOuterSlots = stackSlots;
  for (Operation &op : block.getOperations()) {
    if (llvm::is_contained(skipOps, &op))
      continue;
    StringRef name = op.getName().getStringRef();
    if (name == "hlcf.continue" || name == "hlcf.yield" ||
        name == "hlcf.break")
      continue;
    Value opCondition =
        (condition && !sequenced)
            ? comb::AndOp::create(builder, loc, condition, active)
            : active;
    if (failed(emitOp(&op, opCondition, returnValue)))
      return failure();
  }
  inDynamicLoop = false;
  dynamicLoopSlot = Value();
  dynamicLoopOuterSlots.clear();
  loopRelativeCondition = savedRelative;
  if (running) {
    // Iterate the slot list, not the register maps, so emitted order does not
    // depend on DenseMap hashing.
    for (Value carriedSlot : carried) {
      if (auto it = loopCarriedLogicRegs.find(carriedSlot);
          it != loopCarriedLogicRegs.end()) {
        auto regs = it->second;
        LogicValue bodyNext = loopCarriedLogicNext[carriedSlot];
        LogicValue initial = loopCarriedLogicInit[carriedSlot];
        Value valMuxed =
            comb::MuxOp::create(builder, loc, running, bodyNext.val,
                                initial.val);
        Value xzMuxed = comb::MuxOp::create(builder, loc, running, bodyNext.xz,
                                            initial.xz);
        if (failed(setRegNext(regs.val, valMuxed)) ||
            failed(setRegNext(regs.xz, xzMuxed)))
          return loop->emitError()
                 << "HDL lowering: unsupported carried register form";
        if (sequence.active && loopFollowedByLoop) {
          for (auto &entry : sequence.logic)
            if (entry.slot == carriedSlot) {
              entry.valNext = valMuxed;
              entry.xzNext = xzMuxed;
            }
        }
        continue;
      }
      Value reg = loopCarriedRegs[carriedSlot];
      Value bodyNext = loopCarriedNext[carriedSlot];
      Value initial = loopCarriedInit[carriedSlot];
      Value muxed =
          comb::MuxOp::create(builder, loc, running, bodyNext, initial);
      if (failed(setRegNext(reg, muxed)))
        return loop->emitError()
               << "HDL lowering: unsupported carried register form";
      if (sequence.active && loopFollowedByLoop) {
        for (auto &entry : sequence.carried)
          if (entry.slot == carriedSlot)
            entry.next = muxed;
      }
    }
    for (auto &[slot, reg] : loopCarriedRegs)
      values[slot] = reg;
    for (auto &[slot, regs] : loopCarriedLogicRegs) {
      values[slot] = regs.val;
      logicValues[slot] = regs;
    }
    loopCarriedRegs.clear();
    loopCarriedNext.clear();
    loopCarriedInit.clear();
    loopCarriedLogicRegs.clear();
    loopCarriedLogicNext.clear();
    loopCarriedLogicInit.clear();
  }

  Value one = hw::ConstantOp::create(builder, loc, counterType, 1);
  Value incremented = comb::AddOp::create(builder, loc, counter, one);
  Value zero = hw::ConstantOp::create(builder, loc, counterType, 0);
  // A loop inside a conditional branch only runs while that branch is
  // active. Gate its control (counter, break, done) by the branch condition.
  Value loopEnabled = active;
  if (!sequenced && condition)
    loopEnabled = comb::AndOp::create(builder, loc, condition, active);
  Value breakNow =
      dynamicBreakCond
          ? comb::AndOp::create(builder, loc, loopEnabled, dynamicBreakCond)
          : Value();
  Value atEnd = comb::ICmpOp::create(
      builder, loc, comb::ICmpPredicate::eq, incremented, boundValue);
  Value inRangeLast = comb::AndOp::create(
      builder, loc, childLoopRan ? childLoopLast : loopEnabled, atEnd);
  Value last = breakNow ? comb::OrOp::create(builder, loc, inRangeLast, breakNow)
                        : inRangeLast;
  Value step =
      breakNow ? comb::MuxOp::create(builder, loc, breakNow, boundValue,
                                     incremented)
               : incremented;
  Value idle = loopFollowedByLoop ? counter : zero;
  Value next =
      childLoopRan
          ? comb::MuxOp::create(
                builder, loc, childLoopLast,
                comb::MuxOp::create(builder, loc, last, zero, incremented),
                breakNow ? zero : counter)
          : comb::MuxOp::create(builder, loc, loopEnabled, step, idle);
  if (auto reg = counter.getDefiningOp<seq::CompRegOp>())
    reg->setOperand(0, next);
  else if (auto reg = counter.getDefiningOp<seq::FirRegOp>())
    reg->setOperand(0, next);
  else
    return loop->emitError() << "HDL lowering: unsupported loop counter form";
  if (sequence.active && loopFollowedByLoop)
    sequence.counterNext = next;
  if (started) {
    Value trueValue = getConstant(true);
    Value falseValue = getConstant(false);
    Value hold = comb::MuxOp::create(builder, loc, last, falseValue, started);
    Value next = comb::MuxOp::create(builder, loc, condition, trueValue, hold);
    if (failed(setRegNext(started, next)))
      return loop->emitError()
             << "HDL lowering: unsupported sequenced start form";
  }
  auto i1Type = builder.getI1Type();
  llvm::APInt zeroBit(1, 0);
  Value done = createRegister(loopRegisterId++, i1Type, zeroBit, zeroBit,
                              resetStyle);
  if (auto reg = done.getDefiningOp<seq::CompRegOp>())
    reg->setOperand(0, last);
  else if (auto reg = done.getDefiningOp<seq::FirRegOp>())
    reg->setOperand(0, last);
  if (running) {

    Value notLast = bitNot(last);
    Value runningBase =
        comb::MuxOp::create(builder, loc, running, notLast,
                            getConstant(true));
    Value runningNext =
        loopFollowedByLoop
            ? getConstant(true)
            : (started ? comb::MuxOp::create(builder, loc, started,
                                             runningBase, getConstant(false))
                       : runningBase);
    if (!sequenced && condition)
      runningNext = comb::MuxOp::create(builder, loc, condition, runningNext,
                                        getConstant(false));
    if (failed(setRegNext(running, runningNext)))
      return loop->emitError()
             << "HDL lowering: unsupported running register form";
    if (sequence.active && loopFollowedByLoop)
      sequence.runningNext = runningNext;
    loopCarriedRegs.clear();
    loopCarriedNext.clear();
    loopCarriedInit.clear();
    loopCarriedLogicRegs.clear();
    loopCarriedLogicNext.clear();
    loopCarriedLogicInit.clear();
    loopRunning = Value();
  }
  if (sequence.active && !loopFollowedByLoop) {
    auto patchNext = [&](Value reg, Value oldNext, Value restartValue) {
      if (!reg)
        return;
      Value patched =
          comb::MuxOp::create(builder, loc, done, restartValue, oldNext);
      if (auto cr = reg.getDefiningOp<seq::CompRegOp>())
        cr->setOperand(0, patched);
      else if (auto fr = reg.getDefiningOp<seq::FirRegOp>())
        fr->setOperand(0, patched);
    };
    patchNext(sequence.running, sequence.runningNext, getConstant(false));
    auto counterType = sequence.counter.getType();
    patchNext(sequence.counter, sequence.counterNext,
              hw::ConstantOp::create(
                  builder, loc,
                  llvm::APInt(counterType.getIntOrFloatBitWidth(), 0)));
    for (auto &entry : sequence.carried)
      patchNext(entry.reg, entry.next, entry.init);
    for (auto &entry : sequence.logic) {
      patchNext(entry.valReg, entry.valNext, entry.valInit);
      patchNext(entry.xzReg, entry.xzNext, entry.xzInit);
    }
    sequence = SequenceState();
  }
  if (loopStack.empty())
    pendingLoopDone = done;
  return success();
}

LogicalResult CirctModuleEmitter::emitNestedRangeLoop(
    Operation *loop, Value condition, Value &returnValue, bool &handled) {
  handled = false;
  if (!inDynamicLoop)
    return success();
  if (loop->getNumRegions() != 1 || loop->getRegion(0).empty())
    return success();
  Block &block = loop->getRegion(0).front();

  Operation *nextOp = nullptr;
  Value iterator;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "kgen.call" &&
        callCalleeName(&op).contains("::_ZeroStartingRange::__next__")) {
      nextOp = &op;
      iterator = op.getOperand(0);
      break;
    }
  if (!nextOp || nextOp->getNumOperands() < 2)
    return success();
  auto range = resolveRange(iterator);
  if (!range || !range->runtimeBound)
    return success();
  Value bound = range->runtimeBound;

  Value byrefResult = nextOp->getOperand(nextOp->getNumOperands() - 1);
  Operation *indLoad = nullptr;
  for (Operation &op : block.getOperations())
    if (op.getName().getStringRef() == "pop.load" &&
        op.getOperand(0) == byrefResult) {
      indLoad = &op;
      break;
    }
  Operation *indStore = nullptr;
  Value slot;
  if (indLoad)
    for (Operation &op : block.getOperations())
      if (op.getName().getStringRef() == "pop.store" &&
          op.getNumOperands() == 2 &&
          op.getOperand(0) == indLoad->getResult(0) &&
          !fieldPtrs.count(op.getOperand(1))) {
        indStore = &op;
        slot = op.getOperand(1);
        break;
      }

  Operation *loopIf = nullptr;
  for (Operation &op : block.getOperations()) {
    if (op.getName().getStringRef() != "hlcf.if" || op.getNumOperands() != 1 ||
        op.getOperand(0) != nextOp->getResult(0))
      continue;
    auto hasBreak = [](Region &region) {
      if (region.empty())
        return false;
      for (Operation &inner : region.front())
        if (inner.getName().getStringRef() == "hlcf.break")
          return true;
      return false;
    };
    if (hasBreak(op.getRegion(0)) != hasBreak(op.getRegion(1))) {
      loopIf = &op;
      break;
    }
  }
  if (!loopIf)
    return success();
  for (Value innerCarried : collectLoopCarriedSlots(block, slot))
    if (!loopCarriedRegs.count(innerCarried) &&
        !loopCarriedLogicRegs.count(innerCarried))
      return loop->emitError()
             << "HDL lowering: loop-carried local declared inside the outer "
                "loop is not supported yet";

  handled = true;

  auto resizeTo = [&](Value value, unsigned target) -> Value {
    unsigned width = value.getType().getIntOrFloatBitWidth();
    if (width == target)
      return value;
    if (width < target) {
      Value zeros = hw::ConstantOp::create(
          builder, loc, llvm::APInt(target - width, 0));
      return comb::ConcatOp::create(builder, loc,
                                    ArrayRef<Value>{zeros, value});
    }
    return comb::ExtractOp::create(builder, loc, value, 0, target);
  };
  unsigned width = 64;
  if (auto intType = dyn_cast<IntegerType>(bound.getType()))
    width = intType.getWidth();
  auto counterType = IntegerType::get(builder.getContext(), width);
  llvm::APInt zeroBits(width, 0);
  Value innerCounter = createRegister(loopRegisterId++, counterType,
                                      zeroBits, zeroBits, resetStyle);
  if (slot) {
    slotConstants.erase(slot);
    rangeValues.erase(slot);
    values[slot] = innerCounter;
  }
  Value innerBound = resizeTo(bound, width);
  Value run = condition ? condition : getConstant(true);
  Value innerActive =
      comb::ICmpOp::create(builder, loc, comb::ICmpPredicate::ult,
                           innerCounter, innerBound);
  Value active = comb::AndOp::create(builder, loc, run, innerActive);

  Value savedBreakCond = dynamicBreakCond;
  Value savedRelative = loopRelativeCondition;
  childLoopRan = false;
  childLoopLast = Value();
  dynamicBreakCond = Value();
  loopRelativeCondition = Value();
  SmallVector<Operation *> skipOps{nextOp, loopIf};
  if (indLoad)
    skipOps.push_back(indLoad);
  if (indStore)
    skipOps.push_back(indStore);
  for (Operation &op : block.getOperations()) {
    if (llvm::is_contained(skipOps, &op))
      continue;
    StringRef name = op.getName().getStringRef();
    if (name == "hlcf.continue" || name == "hlcf.yield" ||
        name == "hlcf.break")
      continue;
    if (failed(emitOp(&op, active, returnValue)))
      return failure();
  }

  Value innerBreak = dynamicBreakCond;
  dynamicBreakCond = savedBreakCond;
  loopRelativeCondition = savedRelative;
  Value breakNow =
      innerBreak
          ? comb::AndOp::create(builder, loc, active, innerBreak)
          : Value();
  Value one = hw::ConstantOp::create(builder, loc, counterType, 1);
  Value innerIncremented = comb::AddOp::create(builder, loc, innerCounter, one);
  Value innerZero = hw::ConstantOp::create(builder, loc, counterType, 0);
  Value innerAtEnd = comb::ICmpOp::create(
      builder, loc, comb::ICmpPredicate::eq, innerIncremented, innerBound);
  Value inRangeLast = comb::AndOp::create(
      builder, loc, childLoopRan ? childLoopLast : active, innerAtEnd);
  Value myLast = breakNow
                     ? comb::OrOp::create(builder, loc, inRangeLast, breakNow)
                     : inRangeLast;
  Value resetStep =
      comb::MuxOp::create(builder, loc, myLast, innerZero, innerIncremented);
  Value step =
      breakNow
          ? comb::MuxOp::create(builder, loc, breakNow, innerBound, resetStep)
          : resetStep;
  Value innerNext =
      childLoopRan
          ? comb::MuxOp::create(builder, loc, childLoopLast, step,
                                breakNow ? innerZero : innerCounter)
          : comb::MuxOp::create(builder, loc, active, step, innerZero);
  if (auto cr = innerCounter.getDefiningOp<seq::CompRegOp>())
    cr->setOperand(0, innerNext);
  else if (auto fr = innerCounter.getDefiningOp<seq::FirRegOp>())
    fr->setOperand(0, innerNext);
  else
    return loop->emitError()
           << "HDL lowering: unsupported nested loop counter form";

  childLoopRan = true;
  childLoopLast = myLast;
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
    builder.setInsertionPoint(body->getTerminator());
    clk = domainClk[m];
    if (clockDivisor > 1)
      clk = seq::ClockDividerOp::create(builder, loc, clk,
                                        builder.getI64IntegerAttr(clockDivisor));
    resetSignal = domainReset[m];
    returnIsLogic = false;
    returnXz = Value();

    Value returnValue;
    returnSites.clear();
    pendingLoopDone = Value();
    currentStartPulse = Value();
    sequence = SequenceState();
    if (failed(emitOps(methods[m], returnValue)))
      return failure();
    // Fold branch returns into one value. Later returns are fallbacks for
    // earlier conditional ones, so walk the sites in reverse emission order.
    // A site's value and four-state mask are muxed together.
    if (!returnSites.empty()) {
      Value result = returnSites.back().value;
      Value resultXz = returnSites.back().xz;
      for (size_t i = returnSites.size() - 1; i-- > 0;) {
        ReturnSite &site = returnSites[i];
        if (site.condition) {
          result = comb::MuxOp::create(builder, loc, site.condition,
                                       site.value, result);
          if (resultXz)
            resultXz = comb::MuxOp::create(builder, loc, site.condition,
                                           site.xz, resultXz);
        } else {
          result = site.value;
          resultXz = site.xz;
        }
      }
      returnValue = result;
      if (returnXz)
        returnXz = resultXz;
    }
    if (methodOutputCounts[m] == 0)
      continue;
    if (!returnValue || (returnIsLogic && !returnXz))
      return methods[m]->emitError()
             << "HDL lowering: no value for module output";
    outputValues.push_back(returnValue);
    if (returnIsLogic)
      outputValues.push_back(returnXz);
  }

  // Report direct child-state accesses now that every process has a domain.
  for (auto &[field, accesses] : childFieldAccesses) {
    auto owner = instanceMethod.find(field);
    for (const ChildFieldAccess &access : accesses) {
      if (owner != instanceMethod.end() &&
          owner->second != access.method)
        return source.emitError()
               << "HDL lowering: child instance '" << fieldNames[field]
               << "' is ticked from process '" << methodNames[owner->second]
               << "' (domain '" << domainName(owner->second)
               << "') but its field " << access.member
               << " is accessed from process '" << methodNames[access.method]
               << "' (domain '" << domainName(access.method)
               << "'); the access crosses clock domains";
      if (owner == instanceMethod.end())
        return source.emitError()
               << "HDL lowering: child instance '" << fieldNames[field]
               << "' is not ticked in process '" << methodNames[access.method]
               << "'; access its state through a method instead of reading "
               << "field " << access.member << " directly";
      return source.emitError()
             << "HDL lowering: child instance '" << fieldNames[field]
             << "' is ticked from process '" << methodNames[access.method]
             << "'; access its state through a method instead of reading "
             << "field " << access.member << " directly";
    }
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
               << "' (domain '" << domainName(reader)
               << "') but driven from '" << methodNames[writer->second]
               << "' (domain '" << domainName(writer->second)
               << "'); the access crosses clock domains";
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

    // `--emit=sim-step`: derive native-Sim processes from the elaborated
    // `@module` method signatures and print a step adapter. No CIRCT module is
    // built.
    if (options.simStep) {
      OwningOpRef<ModuleOp> scratch = ModuleOp::create(module.getLoc());
      SmallVector<std::pair<std::string, SmallVector<std::string>>> adapters;
      for (const ModuleSpec &spec : collectModuleSpecs(module, modules)) {
        CirctModuleEmitter emitter(module, spec.structName, spec.displayName,
                                   spec.bindings, *scratch, modules);
        SmallVector<std::string> processes;
        if (failed(emitter.collectProcesses(processes))) {
          signalPassFailure();
          return;
        }
        if (processes.empty())
          continue;
        adapters.emplace_back(spec.displayName, std::move(processes));
      }
      if (adapters.empty()) {
        module.emitError()
            << "HDL simulation: no process method found; a process is a "
               "`mut self` method with no other arguments and no result";
        signalPassFailure();
        return;
      }
      os << "from hdl import commit_state\n\n";
      for (auto &[name, processes] : adapters) {
        os << "def " << name << "_step(mut sim: " << name << "):\n";
        for (const std::string &process : processes)
          os << "    sim." << process << "()\n";
        os << "    commit_state(sim)\n\n";
      }
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

LogicalResult lowerHDLArrayRegToSV(ModuleOp module) {
  module.getContext()->getOrLoadDialect<sv::SVDialect>();
  SmallVector<seq::FirRegOp> regs;
  module.walk([&](seq::FirRegOp reg) {
    if (isa<hw::ArrayType>(reg.getType()))
      regs.push_back(reg);
  });

  for (seq::FirRegOp reg : regs) {
    auto arrayType = cast<hw::ArrayType>(reg.getType());
    hw::ArrayInjectOp inject;
    hw::ArrayGetOp get;
    comb::MuxOp mux;
    bool valid = true;
    for (Operation *user : reg.getResult().getUsers()) {
      if (auto op = dyn_cast<hw::ArrayInjectOp>(user)) {
        if (inject) { valid = false; break; }
        inject = op;
      } else if (auto op = dyn_cast<hw::ArrayGetOp>(user)) {
        if (get) { valid = false; break; }
        get = op;
      } else if (auto op = dyn_cast<comb::MuxOp>(user)) {
        if (mux) { valid = false; break; }
        mux = op;
      } else {
        valid = false;
        break;
      }
    }
    if (!valid || !inject || !get || !mux)
      continue;
    if (mux.getTrueValue() != inject.getResult() ||
        mux.getFalseValue() != reg.getResult())
      continue;

    IRRewriter rewriter(module.getContext());
    rewriter.setInsertionPoint(reg);
    auto memType = hw::UnpackedArrayType::get(arrayType.getElementType(),
                                              arrayType.getNumElements());
    Value svMem =
        sv::VarOp::create(rewriter, reg.getLoc(), memType,
                          rewriter.getStringAttr(reg.getName()))
            .getResult();
    unsigned depth = arrayType.getNumElements();
    unsigned width = arrayType.getElementType().getIntOrFloatBitWidth();
    auto indexType = IntegerType::get(
        module.getContext(), std::max(1U, llvm::Log2_64_Ceil(depth)));
    auto indexConstant = [&](unsigned index) -> Value {
      return hw::ConstantOp::create(rewriter, reg.getLoc(), indexType, index);
    };
    auto assignElement = [&](Value memory, Value index, Value value,
                             bool blocking = false) {
      Value memLoc = sv::ArrayIndexInOutOp::create(
          rewriter, reg.getLoc(), memory, index);
      if (blocking)
        sv::BPAssignOp::create(rewriter, reg.getLoc(), memLoc, value);
      else
        sv::PAssignOp::create(rewriter, reg.getLoc(), memLoc, value);
    };

    // Power-on contents from the register preset (`PowerOn` or constructor
    // fill). Individual entries are unpacked from the packed APInt.
    if (IntegerAttr preset = reg.getPresetAttr()) {
      llvm::APInt bits = preset.getValue();
      sv::InitialOp::create(rewriter, reg.getLoc(), [&] {
        for (unsigned k = 0; k < depth; ++k) {
          Value value = hw::ConstantOp::create(
              rewriter, reg.getLoc(), bits.extractBits(width, k * width));
          assignElement(svMem, indexConstant(k), value, /*blocking=*/true);
        }
      });
    }

    // Reset contents from the array-typed reset value.
    SmallVector<Value> resetValues;
    if (Value resetValue = reg.getResetValue())
      if (auto create = resetValue.getDefiningOp<hw::ArrayCreateOp>())
        llvm::append_range(resetValues, create.getInputs());

    Value hwClk = seq::FromClockOp::create(rewriter, reg.getLoc(),
                                           reg.getClk());
    auto body = [&] {
      sv::IfOp::create(rewriter, reg.getLoc(), mux.getCond(), [&] {
        assignElement(svMem, inject.getIndex(), inject.getElement());
      });
    };
    if (Value reset = reg.getReset()) {
      auto resetBody = [&] {
        for (unsigned k = 0; k < resetValues.size(); ++k)
          assignElement(svMem, indexConstant(k), resetValues[k]);
      };
      sv::AlwaysFFOp::create(
          rewriter, reg.getLoc(), sv::EventControl::AtPosEdge, hwClk,
          reg.getIsAsync() ? sv::ResetType::AsyncReset
                           : sv::ResetType::SyncReset,
          sv::EventControl::AtPosEdge, reset, body, resetBody);
    } else {
      sv::AlwaysFFOp::create(rewriter, reg.getLoc(),
                             sv::EventControl::AtPosEdge, hwClk, body);
    }

    rewriter.setInsertionPointAfter(get);
    Value memLoc = sv::ArrayIndexInOutOp::create(
        rewriter, get.getLoc(), svMem, get.getIndex());
    Value readData =
        sv::ReadInOutOp::create(rewriter, get.getLoc(), memLoc);
    get.getResult().replaceAllUsesWith(readData);
    rewriter.eraseOp(get);
    // The mux result feeds the register next operand; collapse that use
    // before erasing the write cone.
    mux.getResult().replaceAllUsesWith(reg.getResult());
    rewriter.eraseOp(mux);
    rewriter.eraseOp(inject);
    SmallVector<Value> zeros;
    for (unsigned k = 0; k < arrayType.getNumElements(); ++k)
      zeros.push_back(hw::ConstantOp::create(
          rewriter, reg.getLoc(), arrayType.getElementType(), 0));
    ValueRange zeroInputs(zeros);
    auto zeroArray =
        hw::ArrayCreateOp::create(rewriter, reg.getLoc(), zeroInputs);
    reg->setOperand(0, zeroArray.getResult());
    rewriter.eraseOp(reg);
  }
  return success();
}

LogicalResult lowerHDLHLMemToSV(ModuleOp module) {
  module.getContext()->getOrLoadDialect<sv::SVDialect>();
  SmallVector<seq::HLMemOp> mems;
  module.walk([&](seq::HLMemOp mem) { mems.push_back(mem); });

  for (seq::HLMemOp mem : mems) {
    auto memType = mem.getMemType();
    if (memType.getRank() != 1)
      return mem.emitError()
             << "HDL lowering: only unidimensional RAM is supported";
    int64_t depth = memType.getShape()[0];
    Type elementType = memType.getElementType();
    Value clk = mem.getClk();
    Value rst = mem.getRst();

    struct WritePort {
      seq::WritePortOp op;
      Value address;
      Value data;
      Value enable;
    };
    SmallVector<WritePort> writes;
    SmallVector<seq::ReadPortOp> reads;
    for (Operation *user : mem.getHandle().getUsers()) {
      if (auto write = dyn_cast<seq::WritePortOp>(user)) {
        if (write.getLatency() != 1)
          return write.emitError()
                 << "HDL lowering: only write latency 1 is supported";
        if (write.getAddresses().size() != 1)
          return write.emitError()
                 << "HDL lowering: only unidimensional RAM is supported";
        writes.push_back({write, write.getAddresses()[0], write.getInData(),
                          write.getWrEn()});
      } else if (auto read = dyn_cast<seq::ReadPortOp>(user)) {
        if (read.getLatency() != 0)
          return read.emitError()
                 << "HDL lowering: only read latency 0 is supported";
        if (read.getAddresses().size() != 1)
          return read.emitError()
                 << "HDL lowering: only unidimensional RAM is supported";
        reads.push_back(read);
      } else {
        return user->emitError()
               << "HDL lowering: unsupported seq.hlmem user";
      }
    }

    IRRewriter rewriter(module.getContext());
    rewriter.setInsertionPoint(mem);
    auto memArrayType = hw::UnpackedArrayType::get(elementType, depth);
    Value svMem =
        sv::VarOp::create(rewriter, mem.getLoc(), memArrayType,
                          rewriter.getStringAttr(mem.getName()))
            .getResult();

    unsigned addrWidth = std::max(1U, llvm::Log2_64_Ceil(depth));
    auto indexType = IntegerType::get(module.getContext(), addrWidth);
    auto assignElement = [&](Value index, Value value,
                             bool blocking = false) {
      Value memLoc = sv::ArrayIndexInOutOp::create(
          rewriter, mem.getLoc(), svMem, index);
      if (blocking)
        sv::BPAssignOp::create(rewriter, mem.getLoc(), memLoc, value);
      else
        sv::PAssignOp::create(rewriter, mem.getLoc(), memLoc, value);
    };
    auto emitAssignments = [&](ArrayAttr values) {
      for (auto [k, attr] : llvm::enumerate(values)) {
        Value index = hw::ConstantOp::create(
            rewriter, mem.getLoc(), indexType, static_cast<unsigned>(k));
        Value value = hw::ConstantOp::create(
            rewriter, mem.getLoc(), cast<IntegerAttr>(attr).getValue());
        assignElement(index, value);
      }
    };
    auto emitInitialValues = [&](ArrayAttr values) {
      for (auto [k, attr] : llvm::enumerate(values)) {
        Value index = hw::ConstantOp::create(
            rewriter, mem.getLoc(), indexType, static_cast<unsigned>(k));
        Value value = hw::ConstantOp::create(
            rewriter, mem.getLoc(), cast<IntegerAttr>(attr).getValue());
        assignElement(index, value, /*blocking=*/true);
      }
    };
    ArrayAttr powerOn = mem->getAttrOfType<ArrayAttr>("hdl.poweron");
    ArrayAttr resetValues = mem->getAttrOfType<ArrayAttr>("hdl.reset");
    if (powerOn) {
      rewriter.setInsertionPoint(mem);
      sv::InitialOp::create(rewriter, mem.getLoc(),
                            [&] { emitInitialValues(powerOn); });
    }

    Value hwClk = seq::FromClockOp::create(rewriter, mem.getLoc(), clk);
    auto body = [&] {
      for (WritePort &write : writes) {
        sv::IfOp::create(rewriter, mem.getLoc(), write.enable, [&] {
          Value memLoc = sv::ArrayIndexInOutOp::create(
              rewriter, mem.getLoc(), svMem, write.address);
          sv::PAssignOp::create(rewriter, mem.getLoc(), memLoc, write.data);
        });
      }
    };
    auto resetBody = [&] {
      if (resetValues)
        emitAssignments(resetValues);
    };
    bool asyncReset = mem->hasAttr("hdl.reset_async");
    sv::AlwaysFFOp::create(
        rewriter, mem.getLoc(), sv::EventControl::AtPosEdge, hwClk,
        asyncReset ? sv::ResetType::AsyncReset : sv::ResetType::SyncReset,
        sv::EventControl::AtPosEdge, rst, body, resetBody);

    for (WritePort &write : writes)
      rewriter.eraseOp(write.op);

    for (seq::ReadPortOp read : reads) {
      rewriter.setInsertionPointAfter(read);
      Value memLoc = sv::ArrayIndexInOutOp::create(
          rewriter, read.getLoc(), svMem, read.getAddresses()[0]);
      Value data =
          sv::ReadInOutOp::create(rewriter, read.getLoc(), memLoc);
      read.getReadData().replaceAllUsesWith(data);
      rewriter.eraseOp(read);
    }
    rewriter.eraseOp(mem);
  }
  return success();
}

LogicalResult exportHDLSystemVerilog(ModuleOp module, raw_ostream &os) {
  return circt::exportVerilog(module, os);
}


} // namespace M::KGEN
