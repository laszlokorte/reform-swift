//
//  ExpressionPrinter.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 10.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class ExpressionPrinter {
    
    let binaryOperators : [String : BinaryOperatorDefinition] = [
        "^" : BinaryOperatorDefinition(BinaryExponentiation.self, Precedence(50), .right),
        "*" : BinaryOperatorDefinition(BinaryMultiplication.self, Precedence(40), .left),
        "/" : BinaryOperatorDefinition(BinaryDivision.self, Precedence(40), .left),
        
        "%" : BinaryOperatorDefinition(BinaryModulo.self, Precedence(40), .left),
        
        "+" : BinaryOperatorDefinition(BinaryAddition.self, Precedence(30), .left),
        "-" : BinaryOperatorDefinition(BinarySubtraction.self, Precedence(30), .left),
        
        "<": BinaryOperatorDefinition(LessThanRelation.self, Precedence(20), .left),
        "<=": BinaryOperatorDefinition(LessThanOrEqualRelation.self, Precedence(20), .left),
        ">": BinaryOperatorDefinition(GreaterThanRelation.self, Precedence(20), .left),
        ">=": BinaryOperatorDefinition(GreaterThanOrEqualRelation.self, Precedence(20), .left),
        "==": BinaryOperatorDefinition(StrictEqualRelation.self, Precedence(10), .left),
        "!=": BinaryOperatorDefinition(StrictNotEqualRelation.self, Precedence(10), .left),
        "&&": BinaryOperatorDefinition(BinaryLogicAnd.self, Precedence(8), .left),
        "||": BinaryOperatorDefinition(BinaryLogicOr.self, Precedence(5), .left),
    ]
    
    let unaryOperators : [String : UnaryOperatorDefinition] = [
        "+" : UnaryOperatorDefinition(UnaryPlus.self, Precedence(45), .left),
        "-" : UnaryOperatorDefinition(UnaryMinus.self, Precedence(45), .left),
        "~" : UnaryOperatorDefinition(UnaryLogicNegation.self, Precedence(45), .left),
    ]
    
    let constants : [String : Value] = [
        "PI" : Value.doubleValue(value: PI),
        "E" : Value.doubleValue(value: E),
    ]
    
    let functions : [String : Function.Type] = [
        "sin" : Sinus.self,
        "asin" : ArcusSinus.self,
        "cos" : Cosinus.self,
        "acos" : ArcusCosinus.self,
        "tan" : Tangens.self,
        "atan" : ArcusTangens.self,
        "atan2" : ArcusTangens.self,
        "exp" : Exponential.self,
        "pow" : Power.self,
        "ln" : NaturalLogarithm.self,
        "log10" : DecimalLogarithm.self,
        "log2" : BinaryLogarithm.self,
        "sqrt" : SquareRoot.self,
        "round" : Round.self,
        "ceil" : Ceil.self,
        "floor" : Floor.self,
        "abs" : Absolute.self,
        "max" : Maximum.self,
        "min" : Minimum.self,
        "count" : Count.self,
        "avg" : Average.self,
        "sum" : Sum.self,
        "random" : Random.self,
        
        "int" : IntCast.self,
        "double" : DoubleCast.self,
        "bool" : BoolCast.self,
        "string" : StringCast.self,
        
        "rgb" : RGBConstructor.self,
        "rgba" : RGBAConstructor.self
    ]
    
    let sheet : Sheet
    
    public init(sheet: Sheet) {
        self.sheet = sheet
    }
    
    private func functionName(_ function : Function) -> String? {
        for (name, type) in functions {
            if function.dynamicType == type {
                return name
            }
        }
        
        return nil
    }
    
    private func findOperator(_ op : BinaryOperator) -> (String,BinaryOperatorDefinition)? {
        for (name, def) in binaryOperators {
            if op.dynamicType == def.op {
                return (name, def)
            }
        }
        
        return nil
    }
    
    private func findOperator(_ op : UnaryOperator) -> (String,UnaryOperatorDefinition)? {
        for (name, def) in unaryOperators {
            if op.dynamicType == def.op {
                return (name, def)
            }
        }
        
        return nil
    }
    
    public func toString(_ value : Value) -> String {
        switch value {
        case .boolValue(let bool):
            return bool ? "true" : "false"
        case .intValue(let int):
            return "\(int)"
        case .doubleValue(let double):
            return String(format: "%.2f", double)
        case .stringValue(let string):
            return "\"\(string)\""
        case .colorValue(let r, let g, let b, let a):
            let f = "%02x"
            return "#\(String(format: f, r))\(String(format: f, g))\(String(format: f, b))\(String(format: f, a))"
        }
    }
    
    public func toString(_ expression : Expression, outerPrecedence : Precedence = Precedence(0), isLeft : Bool = false) -> String? {
        switch(expression) {
        case .constant(let value):
            return toString(value)
        case .namedConstant(let label, _):
            return label
        case .reference(let id):
            return sheet.definitionWithId(id)?.name ?? "[?\(id.value)]"
        case .unary(let op, let expr):
            guard let
                (name, def) = findOperator(op),
                sub = toString(expr, outerPrecedence: def.precedence)
            else {
                return nil
            }
            
            if outerPrecedence < def.precedence {
                return "\(name)\(sub)"
            } else {
                return "(\(name)\(sub))"
            }
        case .binary(let op, let lhs, let rhs):
            guard let
                (name, def) = findOperator(op),
                left = toString(lhs, outerPrecedence: def.precedence, isLeft: true),
                right = toString(rhs,outerPrecedence:  def.precedence)
            else {
                return nil
            }
    
            if outerPrecedence < def.precedence || outerPrecedence == def.precedence && isLeft {
                return "\(left) \(name) \(right)"
            } else {
                return "(\(left) \(name) \(right))"
            }
        case .call(let function, let params):
            if let fname = functionName(function) {
                let pstr = params.flatMap({ toString($0) }).joined(separator: ", ")
                return "\(fname)(\(pstr))"
            } else {
                return nil
            }
        }
    }
    
    public func toString(_ error: ShuntingYardError) -> String {
        switch(error) {
        case .invalidState:
            return "Invalid Parser State"
        case .unexpectedEndOfArgumentList(_):
            return "Unexpected end of argument list"
            
        case .missingOperand(let token, let arity, let missing):
            return "Missing \(missing) operand for \(arity) operator \"\(token.value)\""
            
        case .unknownOperator(let token, let arity):
            return "Unknown \(arity) operator \(token.value)"
            
        case .unknownFunction(let token, let parameters):
            return "Unknown function \(token.value)(\(parameters))"
            
        case .unexpectedToken(let token, let message):
            return "Unexpected token \(token.value). \(message)"
            
        case .mismatchedToken(let token, let open):
            if(open) {
                return "Mismatched opening parenthesis \(token.value)"
            } else {
                return "Mismatched closing parenthesis \(token.value)"
            }
            
        }
    }
    
    public func toString(_ error: EvaluationError) -> String {
        switch error {
        case .unresolvedReference(let message):
            return "Unresolved reference: \(message)"
        case .arithmeticError(let message):
            return "Arithmetic error: \(message)"
        case .typeMismatch(let message):
            return "Type mismatch: \(message)"
        case .parameterCountMismatch(let message):
            return "Parameter count mismatch: \(message)"
        case .duplicateDefinition(referenceId: _):
            return "Duplicate definition for reference"
        }
    }
}
