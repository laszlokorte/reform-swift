//
//  Artihmetic.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Darwin

public let PI = M_PI
public let E = M_E

func coercedNumericBinaryOperation(name: String, lhs: Value, rhs: Value, doubleOp: (Double, Double)->Double, intOp: (Int, Int)->Int) -> Result<Value, EvaluationError> {
    switch(lhs, rhs) {
    case (.IntValue(let left), .IntValue(let right)):
        
        return .Success(Value.IntValue(value: intOp(left, right)))
        
    case (.IntValue(let left), .DoubleValue(let right)):
        
        return .Success(Value.DoubleValue(value: doubleOp(Double(left), right)))
        
    case (.DoubleValue(let left), .IntValue(let right)):
        
        return .Success(Value.DoubleValue(value: doubleOp(left, Double(right))))
        
    case (.DoubleValue(let left), .DoubleValue(let right)):
        
        return .Success(Value.DoubleValue(value: doubleOp(left, right)))
        
    default:
        return .Fail(.TypeMismatch(message: "\(name) is not defined for given operands."))
    }
}

func unaryDoubleOperation(name: String, params: [Value], op: Double->Double) -> Result<Value, EvaluationError> {
    if(params.count != 1) {
        return .Fail(.ParameterCountMismatch(message: "expected one argument"))
    }
    
    switch params[0] {
    case .IntValue(let val):
        return .Success(Value.DoubleValue(value: op(Double(val))))
    case .DoubleValue(let val):
        return .Success(Value.DoubleValue(value: op(val)))
    default:
        return .Fail(.TypeMismatch(message: "\(name) is not defined for given operands."))
    }
}

func binaryDoubleOperation(name: String, params: [Value], op: (Double,Double)->Double) -> Result<Value, EvaluationError> {
    if(params.count != 2) {
        return .Fail(.ParameterCountMismatch(message: "expected one argument"))
    }
    
    switch (params[0], params[1]) {
        case (.IntValue(let left), .IntValue(let right)):
        
        return .Success(Value.DoubleValue(value: op(Double(left), Double(right))))
        
        case (.IntValue(let left), .DoubleValue(let right)):
        
        return .Success(Value.DoubleValue(value: op(Double(left), right)))
        
        case (.DoubleValue(let left), .IntValue(let right)):
        
        return .Success(Value.DoubleValue(value: op(left, Double(right))))
        
        case (.DoubleValue(let left), .DoubleValue(let right)):
        
        return .Success(Value.DoubleValue(value: op(left, right)))
        default:
        return .Fail(.TypeMismatch(message: "\(name) is not defined for given operands."))
    }
}

struct BinaryAddition : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return coercedNumericBinaryOperation("Addition", lhs: lhs, rhs: rhs, doubleOp: +, intOp: +)
    }
}

struct BinarySubtraction : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return coercedNumericBinaryOperation("Subtraction", lhs: lhs, rhs: rhs, doubleOp: -, intOp: -)
    }
}

struct BinaryMultiplication : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return coercedNumericBinaryOperation("Multiplication", lhs: lhs, rhs: rhs, doubleOp: *, intOp: *)
    }
}

struct BinaryDivision : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        if case .IntValue(let right) = rhs where right == 0 {
            return .Fail(.ArithmeticError(message: "Can not devide by 0"))
        }
        
        return coercedNumericBinaryOperation("Division", lhs: lhs, rhs: rhs, doubleOp: /, intOp: /)
    }
}


struct BinaryModulo : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        if case .IntValue(let right) = rhs where right == 0 {
            return .Fail(.ArithmeticError(message: "Can not devide by 0"))
        }
        
        return coercedNumericBinaryOperation("Modulo", lhs: lhs, rhs: rhs, doubleOp: %, intOp: %)
    }
}

struct BinaryExponentiation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return binaryDoubleOperation("Arcus Tangens 2", params: [lhs, rhs], op: pow)
    }
}

struct UnaryMinus : UnaryOperator {
    
    func apply(value: Value) -> Result<Value, EvaluationError> {
        switch value {
        case (.IntValue(let val)):
            return .Success(Value.IntValue(value: -val))
        case (.DoubleValue(let val)):
            return .Success(Value.DoubleValue(value: -val))
        default:
            return .Fail(.TypeMismatch(message: "UnaryMinus is not defined for given operands."))
        }
    }
}

struct UnaryPlus : UnaryOperator {
    
    func apply(value: Value) -> Result<Value, EvaluationError> {
        switch value {
        case (.IntValue(let val)):
            return .Success(Value.IntValue(value: val))
        case (.DoubleValue(let val)):
            return .Success(Value.DoubleValue(value: val))
        default:
            return .Fail(.TypeMismatch(message: "UnaryMinus is not defined for given operands."))
        }
    }
}

struct Random : Function {
    
    static let arity = FunctionArity.Fix(0)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return .Success(.IntValue(value: 42))
    }
}


struct Sinus : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Sinus", params: params, op: sin)
    }
}



struct ArcusSinus : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Arcus Sinus", params: params, op: sin)
    }
}


struct Cosinus : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Cosinus", params: params, op: cos)
    }
}

struct ArcusCosinus : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Arcus Cosinus", params: params, op: acos)
    }
}

struct Tangens : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Tangens", params: params, op: tan)
    }
}

struct ArcusTangens : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Arcus Tangens", params: params, op: atan)
    }
}

struct ArcusTangens2 : Function {
    
    static let arity = FunctionArity.Fix(2)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return binaryDoubleOperation("Arcus Tangens 2", params: params, op: atan2)
    }
}

struct Power : Function {
    
    static let arity = FunctionArity.Fix(2)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return binaryDoubleOperation("Arcus Tangens 2", params: params, op: pow)
    }
}

struct NaturalLogarithm : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Natural Logarithm", params: params, op: log)
    }
}

struct DecimalLogarithm : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Decimal Logarithm", params: params, op: log10)
    }
}

struct BinaryLogarithm : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Decimal Logarithm", params: params, op: log2)
    }
}


struct SquareRoot : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Square Root", params: params, op: sqrt)
    }
}

struct Exponential : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Square Root", params: params, op: sqrt)
    }
}

struct Round : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Round", params: params, op: round)
    }
}

struct Floor : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Floor", params: params, op: floor)
    }
}

struct Ceil : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Ceil", params: params, op: ceil)
    }
}

struct Absolute : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return unaryDoubleOperation("Absolute", params: params, op: abs)
    }
}

struct Maximum : Function {
    
    static let arity = FunctionArity.Variadic
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let result = params.reduce(Optional<Double>.None, combine: { acc, value in
            switch value {
            case .IntValue(let v):
                if let current = acc where current > Double(v) {
                    return current
                } else {
                    return .Some(Double(v))
                }
            case .DoubleValue(let v):
                if let current = acc where current > v {
                    return current
                } else {
                    return v
                }
            default:
                return acc
            }
        }) {
            return .Success(Value.DoubleValue(value: result))
        } else {
            return .Fail(.ArithmeticError(message: "Can not calculate minumum of given types"))
        }
    }
}


struct Minimum : Function {
    
    static let arity = FunctionArity.Variadic
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let result = params.reduce(Optional<Double>.None, combine: { acc, value in
            switch value {
            case .IntValue(let v):
                if let current = acc where current < Double(v) {
                    return current
                } else {
                    return .Some(Double(v))
                }
            case .DoubleValue(let v):
                if let current = acc where current < v {
                    return current
                } else {
                    return v
                }
            default:
                return acc
            }
        }) {
            return .Success(Value.DoubleValue(value: result))
        } else {
            return .Fail(.ArithmeticError(message: "Can not calculate maximum of given types"))
        }
    }
}


struct Count : Function {
    
    static let arity = FunctionArity.Variadic
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        return .Success(.IntValue(value: params.count))
    }
}

struct Sum : Function {
    
    static let arity = FunctionArity.Variadic
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let result = params.reduce(Optional<Double>.None, combine: { acc, value in
            switch value {
            case .IntValue(let v):
                if let current = acc {
                    return current + Double(v)
                } else {
                    return .Some(Double(v))
                }
            case .DoubleValue(let v):
                if let current = acc {
                    return current + v
                } else {
                    return v
                }
            default:
                return acc
            }
        }) {
            return .Success(Value.DoubleValue(value: result))
        } else {
            return .Fail(.ArithmeticError(message: "Can not calculate sum of given types"))
        }
    }
}

struct Average : Function {
    
    static let arity = FunctionArity.Variadic
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        let sum = Sum().apply(params)
        guard params.count > 0 else {
            return .Fail(.ArithmeticError(message: "Can not calculate average of given types"))
        }
        if case .Success(.DoubleValue(let s)) = sum {
            return .Success(.DoubleValue(value: s / Double(params.count)))
        } else {
            return sum
        }
    }
}

