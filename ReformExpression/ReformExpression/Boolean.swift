//
//  Boolean.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

func booleanBinaryOperation(name: String, lhs: Value, rhs: Value, op: (Bool, Bool)->Bool) -> Result<Value, EvaluationError> {
    switch(lhs, rhs) {
    case (.BoolValue(let left), .BoolValue(let right)):
        
        return .Success(Value.BoolValue(value: op(left, right)))
      default:
        return .Fail(.TypeMismatch(message: "\(name) is not defined for given operands."))
    }
}


struct BinaryLogicAnd : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return booleanBinaryOperation("Logic And", lhs: lhs, rhs: rhs, op: {$0 && $1})
    }
}

struct BinaryLogicOr : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return booleanBinaryOperation("Logic Or", lhs: lhs, rhs: rhs, op: {$0 || $1})
    }
}

struct UnaryLogicNegation : UnaryOperator {
    
    func apply(value: Value) -> Result<Value, EvaluationError> {
        switch value {
        case (.BoolValue(let bool)):
            return .Success(Value.BoolValue(value: !bool))
        default:
            return .Fail(.TypeMismatch(message: "Addition is not defined for given operands."))
        }
    }
}


struct GreaterThanRelation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.IntValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left > right))
            
        case (.IntValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: Double(left) > right))
            
        case (.DoubleValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left > Double(right)))
            
        case (.DoubleValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: left > right))
            
        default:
            return .Fail(.TypeMismatch(message: "GreaterThanRelation is not defined for given operands."))
        }
    }
}

struct LessThanRelation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.IntValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left < right))
            
        case (.IntValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: Double(left) < right))
            
        case (.DoubleValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left < Double(right)))
            
        case (.DoubleValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: left < right))
            
        default:
            return .Fail(.TypeMismatch(message: "LessThanRelation is not defined for given operands."))
        }
    }
}

struct GreaterThanOrEqualRelation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.IntValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left >= right))
            
        case (.IntValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: Double(left) >= right))
            
        case (.DoubleValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left >= Double(right)))
            
        case (.DoubleValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: left >= right))
            
        default:
            return .Fail(.TypeMismatch(message: "GreaterThanOrEqualRelation is not defined for given operands."))
        }
    }
}

struct LessThanOrEqualRelation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.IntValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left <= right))
            
        case (.IntValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: Double(left) <= right))
            
        case (.DoubleValue(let left), .IntValue(let right)):
            
            return .Success(Value.BoolValue(value: left <= Double(right)))
            
        case (.DoubleValue(let left), .DoubleValue(let right)):
            
            return .Success(Value.BoolValue(value: left <= right))
            
        default:
            return .Fail(.TypeMismatch(message: "LessThanOrEqualRelation is not defined for given operands."))
        }
    }
}

struct StrictEqualRelation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return .Success(Value.BoolValue(value: lhs == rhs))
        
    }
}

struct StrictNotEqualRelation : BinaryOperator {
    
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return .Success(Value.BoolValue(value: lhs != rhs))
    }
}