//
//  Colors.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

private func clamp<T:Comparable>(_ value: T, minimum: T, maximum: T) -> T {
    return min(maximum, max(minimum, value))
}

private func component(_ value: Value) -> UInt8 {
    switch value {
    case .stringValue(_):
        return UInt8(0)
    case .intValue(let int):
        return UInt8(clamp(int, minimum: 0, maximum: 255))
    case .doubleValue(let double):
        return UInt8(clamp(double, minimum: 0, maximum: 1) * 255)
    case .colorValue(_):
        return UInt8(0)
    case .boolValue(let bool):
        return UInt8(bool ? 255 : 0)
    }
}

struct RGBConstructor : Function {
    
    static let arity = FunctionArity.fix(3)
    
    func apply(_ params: [Value]) -> Result<Value, EvaluationError> {
        guard params.count == 3 else {
            return .fail(.parameterCountMismatch(message: "expected three arguments"))
        }
        
        let r : UInt8 = component(params[0])
        let g : UInt8 = component(params[1])
        let b : UInt8 = component(params[2])
        let a : UInt8 = 255

        return .success(.colorValue(r:r,g:g,b:b,a:a))
    }
}

struct RGBAConstructor : Function {
    
    static let arity = FunctionArity.fix(4)
    
    func apply(_ params: [Value]) -> Result<Value, EvaluationError> {
        guard params.count == 4 else {
            return .fail(.parameterCountMismatch(message: "expected four arguments"))
        }
        
        let r : UInt8 = component(params[0])
        let g : UInt8 = component(params[1])
        let b : UInt8 = component(params[2])
        let a : UInt8 = component(params[3])

        return .success(.colorValue(r:r,g:g,b:b,a:a))
    }
}
