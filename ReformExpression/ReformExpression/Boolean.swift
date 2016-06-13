//
//  Boolean.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

func booleanBinaryOperation(_ name: String, lhs: Value, rhs: Value, op: (Bool, Bool)->Bool) -> Result<Value, EvaluationError> {
    switch(lhs, rhs) {
    case (.boolValue(let left), .boolValue(let right)):
        
        return .success(Value.boolValue(value: op(left, right)))
      default:
        return .fail(.typeMismatch(message: "\(name) is not defined for given operands."))
    }
}


struct BinaryLogicAnd : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return booleanBinaryOperation("Logic And", lhs: lhs, rhs: rhs, op: {$0 && $1})
    }
}

struct BinaryLogicOr : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return booleanBinaryOperation("Logic Or", lhs: lhs, rhs: rhs, op: {$0 || $1})
    }
}

struct UnaryLogicNegation : UnaryOperator {
    
    func apply(_ value: Value) -> Result<Value, EvaluationError> {
        switch value {
        case (.boolValue(let bool)):
            return .success(Value.boolValue(value: !bool))
        default:
            return .fail(.typeMismatch(message: "Addition is not defined for given operands."))
        }
    }
}


struct GreaterThanRelation : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.intValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left > right))
            
        case (.intValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: Double(left) > right))
            
        case (.doubleValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left > Double(right)))
            
        case (.doubleValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: left > right))
            
        default:
            return .fail(.typeMismatch(message: "GreaterThanRelation is not defined for given operands."))
        }
    }
}

struct LessThanRelation : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.intValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left < right))
            
        case (.intValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: Double(left) < right))
            
        case (.doubleValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left < Double(right)))
            
        case (.doubleValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: left < right))
            
        default:
            return .fail(.typeMismatch(message: "LessThanRelation is not defined for given operands."))
        }
    }
}

struct GreaterThanOrEqualRelation : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.intValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left >= right))
            
        case (.intValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: Double(left) >= right))
            
        case (.doubleValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left >= Double(right)))
            
        case (.doubleValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: left >= right))
            
        default:
            return .fail(.typeMismatch(message: "GreaterThanOrEqualRelation is not defined for given operands."))
        }
    }
}

struct LessThanOrEqualRelation : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        switch(lhs, rhs) {
        case (.intValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left <= right))
            
        case (.intValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: Double(left) <= right))
            
        case (.doubleValue(let left), .intValue(let right)):
            
            return .success(Value.boolValue(value: left <= Double(right)))
            
        case (.doubleValue(let left), .doubleValue(let right)):
            
            return .success(Value.boolValue(value: left <= right))
            
        default:
            return .fail(.typeMismatch(message: "LessThanOrEqualRelation is not defined for given operands."))
        }
    }
}

struct StrictEqualRelation : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return .success(Value.boolValue(value: lhs == rhs))
        
    }
}

struct StrictNotEqualRelation : BinaryOperator {
    
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError> {
        return .success(Value.boolValue(value: lhs != rhs))
    }
}
