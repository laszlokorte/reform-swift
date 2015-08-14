//
//  ExpressionPrinter.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 10.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public class ExpressionPrinter {
    
    let binaryOperators : [String : BinaryOperatorDefinition] = [
        "^" : BinaryOperatorDefinition(BinaryExponentiation.self, Precedence(50), .Right),
        "*" : BinaryOperatorDefinition(BinaryMultiplication.self, Precedence(40), .Left),
        "/" : BinaryOperatorDefinition(BinaryDivision.self, Precedence(40), .Left),
        
        "%" : BinaryOperatorDefinition(BinaryModulo.self, Precedence(40), .Left),
        
        "+" : BinaryOperatorDefinition(BinaryAddition.self, Precedence(30), .Left),
        "-" : BinaryOperatorDefinition(BinarySubtraction.self, Precedence(30), .Left),
        
        "<": BinaryOperatorDefinition(LessThanRelation.self, Precedence(20), .Left),
        "<=": BinaryOperatorDefinition(LessThanOrEqualRelation.self, Precedence(20), .Left),
        ">": BinaryOperatorDefinition(GreaterThanRelation.self, Precedence(20), .Left),
        ">=": BinaryOperatorDefinition(GreaterThanOrEqualRelation.self, Precedence(20), .Left),
        "==": BinaryOperatorDefinition(StrictEqualRelation.self, Precedence(10), .Left),
        "!=": BinaryOperatorDefinition(StrictNotEqualRelation.self, Precedence(10), .Left),
        "&&": BinaryOperatorDefinition(BinaryLogicAnd.self, Precedence(8), .Left),
        "||": BinaryOperatorDefinition(BinaryLogicOr.self, Precedence(5), .Left),
    ]
    
    let unaryOperators : [String : UnaryOperatorDefinition] = [
        "+" : UnaryOperatorDefinition(UnaryPlus.self, Precedence(45), .Left),
        "-" : UnaryOperatorDefinition(UnaryMinus.self, Precedence(45), .Left),
        "~" : UnaryOperatorDefinition(UnaryLogicNegation.self, Precedence(45), .Left),
    ]
    
    let constants : [String : Value] = [
        "PI" : Value.DoubleValue(value: PI),
        "E" : Value.DoubleValue(value: E),
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
    
    init(sheet: Sheet) {
        self.sheet = sheet
    }
    
    private func functionName(function : Function) -> String? {
        for (name, type) in functions {
            if function.dynamicType == type {
                return name
            }
        }
        
        return nil
    }
    
    private func findOperator(op : BinaryOperator) -> (String,BinaryOperatorDefinition)? {
        for (name, def) in binaryOperators {
            if op.dynamicType == def.op {
                return (name, def)
            }
        }
        
        return nil
    }
    
    private func findOperator(op : UnaryOperator) -> (String,UnaryOperatorDefinition)? {
        for (name, def) in unaryOperators {
            if op.dynamicType == def.op {
                return (name, def)
            }
        }
        
        return nil
    }
    
    public func toString(value : Value) -> String {
        switch value {
        case .BoolValue(let bool):
            return bool ? "true" : "false"
        case .IntValue(let int):
            return "\(int)"
        case .DoubleValue(let double):
            return "\(double)"
        case .StringValue(let string):
            return "\"\(string)\""
        case .ColorValue(let r, let g, let b, let a):
            let f = "%02x"
            return "#\(String(format: f, r))\(String(format: f, g))\(String(format: f, b))\(String(format: f, a))"
        }
    }
    
    public func toString(expression : Expression, outerPrecedence : Precedence = Precedence(0), isLeft : Bool = false) -> String? {
        switch(expression) {
        case .Constant(let value):
            return toString(value)
        case .NamedConstant(let label, _):
            return label
        case .Reference(let id):
            return sheet.definitionWithId(id)?.name ?? "[?\(id.id)]"
        case .Unary(let op, let expr):
            if let (name, def) = findOperator(op), let sub = toString(expr, outerPrecedence: def.precedence) {
                if outerPrecedence < def.precedence {
                    return "\(name)\(sub)"
                } else {
                    return "(\(name)\(sub))"
                }
            } else { return nil }
        case .Binary(let op, let lhs, let rhs):
            if let (name, def) = findOperator(op),
                let left = toString(lhs, outerPrecedence: def.precedence, isLeft: true),
                let right = toString(rhs,outerPrecedence:  def.precedence) {
                    
                    if outerPrecedence < def.precedence || outerPrecedence == def.precedence && isLeft {
                        return "\(left) \(name) \(right)"
                    } else {
                        return "(\(left) \(name) \(right))"
                    }
            } else { return nil }
        case .Call(let function, let params):
            if let fname = functionName(function) {
                let pstr = ", ".join(params.flatMap({ toString($0) }))
                return "\(fname)(\(pstr))"
            } else {
                return nil
            }
        }
    }
    
    public func toString(error: ShuntingYardError) -> String {
        switch(error) {
        case .InvalidState:
            return "Invalid Parser State"
        case .UnexpectedEndOfArgumentList(_):
            return "Unexpected end of argument list"
            
        case .MissingOperand(let token, let arity, let missing):
            return "Missing \(missing) operand for \(arity) operator \"\(token.value)\""
            
        case .UnknownOperator(let token, let arity):
            return "Unknown \(arity) operator \(token.value)"
            
        case .UnknownFunction(let token, let parameters):
            return "Unknown function \(token.value)(\(parameters))"
            
        case .UnexpectedToken(let token, let message):
            return "Unexpected token \(token.value). \(message)"
            
        case .MismatchedToken(let token, let open):
            if(open) {
                return "Mismatched opening parenthesis \(token.value)"
            } else {
                return "Mismatched closing parenthesis \(token.value)"
            }
            
        }
    }
    
    public func toString(error: EvaluationError) -> String {
        switch error {
        case .UnresolvedReference(let message):
            return "Unresolved reference: \(message)"
        case .ArithmeticError(let message):
            return "Arithmetic error: \(message)"
        case .TypeMismatch(let message):
            return "Type mismatch: \(message)"
        case .ParameterCountMismatch(let message):
            return "Parameter count mismatch: \(message)"
        }
    }
}