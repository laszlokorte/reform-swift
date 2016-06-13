//
//  Conversions.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


struct IntCast : Function {
    
    static let arity = FunctionArity.fix(1)
    
    func apply(_ params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .stringValue(_):
                return .success(.intValue(value: 0))
            case .intValue(let value):
                return .success(.intValue(value: value))
            case .doubleValue(let value):
                return .success(.intValue(value: Int(value)))
            case .colorValue(_):
                return .success(.intValue(value: 0))
            case .boolValue(let value):
                return .success(.intValue(value: value ? 1 : 0))
            }
        } else {
            return .fail(.parameterCountMismatch(message: "expected one argument"))
        }
    }
}


struct DoubleCast : Function {
    
    static let arity = FunctionArity.fix(1)
    
    func apply(_ params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .stringValue(_):
                return .success(.doubleValue(value: 0))
            case .intValue(let value):
                return .success(.doubleValue(value: Double(value)))
            case .doubleValue(let value):
                return .success(.doubleValue(value: value))
            case .colorValue(_):
                return .success(.doubleValue(value: 0))
            case .boolValue(let value):
                return .success(.doubleValue(value: value ? 1 : 0))
            }
        } else {
            return .fail(.parameterCountMismatch(message: "expected one argument"))
        }
    }
}

struct StringCast : Function {
    
    static let arity = FunctionArity.fix(1)
    
    func apply(_ params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .stringValue(let value):
                return .success(.stringValue(value: value))
            case .intValue(let value):
                return .success(.stringValue(value: String(value)))
            case .doubleValue(let value):
                return .success(.stringValue(value: String(value)))
            case .colorValue(let r, let g, let b, let a):
                return .success(.stringValue(value: "#\(hex(r))\(hex(g))\(hex(b))\(hex(a))"))
            case .boolValue(let value):
                return .success(.stringValue(value: value ? "true" : "false"))
            }
        } else {
            return .fail(.parameterCountMismatch(message: "expected one argument"))
        }
    }
    
    private func hex(_ num: UInt8) -> String {
        return String(num, radix: 16)
    }
}

struct BoolCast : Function {
    
    static let arity = FunctionArity.fix(1)
    
    func apply(_ params: [Value]) -> Result<Value, EvaluationError> {
        if let p = params.first {
            switch p {
            case .boolValue(let value):
                return .success(.boolValue(value: value))
            default:
                return .success(.boolValue(value: false))
            }
        } else {
            return .fail(.parameterCountMismatch(message: "expected one argument"))
        }
    }
    
    private func hex(_ num: UInt8) -> String {
        return String(num, radix: 16)
    }
}
