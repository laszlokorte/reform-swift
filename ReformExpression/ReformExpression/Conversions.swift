//
//  Conversions.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


struct IntCast : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .StringValue(_):
                return .Success(.IntValue(value: 0))
            case .IntValue(let value):
                return .Success(.IntValue(value: value))
            case .DoubleValue(let value):
                return .Success(.IntValue(value: Int(value)))
            case .ColorValue(_):
                return .Success(.IntValue(value: 0))
            case .BoolValue(let value):
                return .Success(.IntValue(value: value ? 1 : 0))
            }
        } else {
            return .Fail(.ParameterCountMismatch(message: "expected one argument"))
        }
    }
}


struct DoubleCast : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .StringValue(_):
                return .Success(.DoubleValue(value: 0))
            case .IntValue(let value):
                return .Success(.DoubleValue(value: Double(value)))
            case .DoubleValue(let value):
                return .Success(.DoubleValue(value: value))
            case .ColorValue(_):
                return .Success(.DoubleValue(value: 0))
            case .BoolValue(let value):
                return .Success(.DoubleValue(value: value ? 1 : 0))
            }
        } else {
            return .Fail(.ParameterCountMismatch(message: "expected one argument"))
        }
    }
}

struct StringCast : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .StringValue(let value):
                return .Success(.StringValue(value: value))
            case .IntValue(let value):
                return .Success(.StringValue(value: String(value)))
            case .DoubleValue(let value):
                return .Success(.StringValue(value: String(value)))
            case .ColorValue(let r, let g, let b, let a):
                return .Success(.StringValue(value: "#\(hex(r))\(hex(g))\(hex(b))\(hex(a))"))
            case .BoolValue(let value):
                return .Success(.StringValue(value: value ? "true" : "false"))
            }
        } else {
            return .Fail(.ParameterCountMismatch(message: "expected one argument"))
        }
    }
    
    private func hex(num: UInt8) -> String {
        return String(num, radix: 16)
    }
}

struct BoolCast : Function {
    
    static let arity = FunctionArity.Fix(1)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .BoolValue(let value):
                return .Success(.BoolValue(value: value))
            default:
                return .Success(.BoolValue(value: false))
            }
        } else {
            return .Fail(.ParameterCountMismatch(message: "expected one argument"))
        }
    }
    
    private func hex(num: UInt8) -> String {
        return String(num, radix: 16)
    }
}