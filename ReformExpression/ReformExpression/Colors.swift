//
//  Colors.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

private func clamp<T:Comparable>(value: T, minimum: T, maximum: T) -> T {
    return min(maximum, max(minimum, value))
}

private func component(value: Value) -> UInt8 {
    switch value {
    case .StringValue(_):
        return UInt8(0)
    case .IntValue(let int):
        return UInt8(clamp(int, minimum: 0, maximum: 255))
    case .DoubleValue(let double):
        return UInt8(clamp(double, minimum: 0, maximum: 1) * 255)
    case .ColorValue(_):
        return UInt8(0)
    case .BoolValue(let bool):
        return UInt8(bool ? 255 : 0)
    }
}

struct RGBConstructor : Function {
    
    static let arity = FunctionArity.Fix(3)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        guard params.count == 3 else {
            return .Fail(.ParameterCountMismatch(message: "expected three arguments"))
        }
        
        let r : UInt8 = component(params[0])
        let g : UInt8 = component(params[1])
        let b : UInt8 = component(params[2])
        let a : UInt8 = 255

        return .Success(.ColorValue(r:r,g:g,b:b,a:a))
    }
}

struct RGBAConstructor : Function {
    
    static let arity = FunctionArity.Fix(4)
    
    func apply(params: [Value]) -> Result<Value, EvaluationError> {
        guard params.count == 4 else {
            return .Fail(.ParameterCountMismatch(message: "expected four arguments"))
        }
        
        let r : UInt8 = component(params[0])
        let g : UInt8 = component(params[1])
        let b : UInt8 = component(params[2])
        let a : UInt8 = component(params[3])

        return .Success(.ColorValue(r:r,g:g,b:b,a:a))
    }
}