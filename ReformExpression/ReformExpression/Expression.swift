//
//  Expression.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum EvaluationError : ErrorProtocol {
    case unresolvedReference(message: String)
    case arithmeticError(message: String)
    case typeMismatch(message: String)
    case parameterCountMismatch(message: String)
    case duplicateDefinition(referenceId: ReferenceId)
}

public protocol UnaryOperator {
    init()
    func apply(_ value: Value) -> Result<Value, EvaluationError>
}

public protocol BinaryOperator {
    init()
    func apply(_ lhs: Value, rhs: Value) -> Result<Value, EvaluationError>
}

public enum FunctionArity {
    case fix(Int)
    case variadic
    
    func accept(_ count: Int) -> Bool {
        switch self {
        case fix(count):
            return true
        case .variadic:
            return true
        default:
            return false
        }
    }
}

public protocol Function {
    static var arity : FunctionArity { get }
    init()
    func apply(_ params: [Value]) -> Result<Value, EvaluationError>
}

public func ==(left: ReferenceId, right: ReferenceId) -> Bool {
    return left.value == right.value
}

public enum Expression : Equatable {
    case constant(Value)
    case namedConstant(String, Value)
    case reference(id: ReferenceId)
    indirect case unary(UnaryOperator, Expression)
    indirect case binary(BinaryOperator, Expression, Expression)
    indirect case call(Function, [Expression])
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case (.constant(let l), .constant(let r)):
        return l == r
    case (.namedConstant(let l), .namedConstant(let r)):
        return l.0 == r.0 && l.1 == r.1
    case (.reference(let l), .reference(let r)):
        return l == r
    case (.unary(let opl,let l), .unary(let opr, let r)):
        return opl.dynamicType == opr.dynamicType && l == r
    case (.binary(let opl,let l1, let l2), .binary(let opr, let r1, let r2)):
        return opl.dynamicType == opr.dynamicType && l1 == r1 && l2 == r2
    case (.call(let fl, let argl), .call(let fr, let argr)):
        return fl.dynamicType == fr.dynamicType && argl == argr
        
    default:
        return false
    }
}

extension Expression {
    public func eval(_ dataSet: DataSet) -> Result<Value, EvaluationError> {
        switch(self) {
        case .constant(let value):
            return .success(value)
        case .namedConstant(_, let value):
            return .success(value)
        case .reference(let id):
            if let value = dataSet.lookUp(id) {
                return .success(value)
            } else {
                return .fail(.unresolvedReference(message: "[?\(id.value)]"))
            }
        case .unary(let op, let expr):
            switch expr.eval(dataSet) {
            case .success(let val):
                return op.apply(val)
            case .fail(let error):
                return .fail(error)
            }
        case .binary(let op, let lhs, let rhs):
            
            switch lhs.eval(dataSet) {
            case .success(let leftValue):
                switch rhs.eval(dataSet) {
                case .success(let rightValue):
                    return op.apply(leftValue, rhs: rightValue)
                case .fail(let rightError):
                    return .fail(rightError)
                }
            case .fail(let leftError):
                return .fail(leftError)
            }
        case .call(let function, let params):
            guard function.dynamicType.arity.accept(params.count) else {
                return .fail(.parameterCountMismatch(message: "Amount of parameters does not match"))
            }
            
            var paramValues = [Value]()
            for p in params {
                switch p.eval(dataSet) {
                case .success(let value):
                    paramValues.append(value)
                case .fail(let error):
                    return .fail(error)
                }
            }
            
            return function.apply(paramValues)
        }
    }
}
