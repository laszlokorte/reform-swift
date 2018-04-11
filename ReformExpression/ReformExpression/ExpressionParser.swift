//
//  MyParser.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 08.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation

struct BinaryOperatorDefinition {
    let op : BinaryOperator.Type
    let precedence : Precedence
    let associativity : Associativity
    
    init(_ op: BinaryOperator.Type, _ precedence : Precedence, _ assoc : Associativity) {
        self.op = op
        self.precedence = precedence
        self.associativity = assoc
    }
}

struct UnaryOperatorDefinition {
    let op : UnaryOperator.Type
    let precedence : Precedence
    let associativity : Associativity
    
    init(_ op: UnaryOperator.Type, _ precedence : Precedence, _ assoc : Associativity) {
        self.op = op
        self.precedence = precedence
        self.associativity = assoc
    }
}

final public class ExpressionParserDelegate : ShuntingYardDelegate {
    public typealias NodeType = Expression
    
    private let sheet : Sheet
    
    public init(sheet: Sheet) {
        self.sheet = sheet
    }
    
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
        "PI" : Value.doubleValue(value: Double.pi),
        "E" : Value.doubleValue(value: M_E),
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
    
    let matchingPairs : [String:String] = ["(":")"]
    
    public func isMatchingPair(_ left : Token<ShuntingYardTokenType>, right : Token<ShuntingYardTokenType>) -> Bool {
        return matchingPairs[left.value] == right.value
    }
    public func variableTokenToNode(_ token : Token<ShuntingYardTokenType>) throws -> Expression {
        if let definition = sheet.definitionWithName(token.value) {
            return .reference(id: definition.id)
        } else {
            throw ShuntingYardError.unexpectedToken(token: token, message: "unknown identifier")
        }
    }
    
    public func constantTokenToNode(_ token : Token<ShuntingYardTokenType>) throws -> Expression {
        if let val = constants[token.value] {
            return Expression.namedConstant(token.value, val)
        } else {
            throw ShuntingYardError.unexpectedToken(token: token, message: "")
        }
    }
    
    public func emptyNode() throws -> Expression {
        return Expression.constant(.intValue(value: 0))
    }
    
    public func unaryOperatorToNode(_ op : Token<ShuntingYardTokenType>, operand : Expression) throws -> Expression {
        if let o = unaryOperators[op.value] {
            return Expression.unary(o.op.init(), operand)
        } else {
            throw ShuntingYardError.unknownOperator(token: op, arity: OperatorArity.unary)
        }
    }
    
    public func binaryOperatorToNode(_ op : Token<ShuntingYardTokenType>, leftHand : Expression, rightHand : Expression) throws -> Expression {
        
        if let o = binaryOperators[op.value] {
            return Expression.binary(o.op.init(), leftHand, rightHand)
        } else {
            throw ShuntingYardError.unknownOperator(token: op, arity: OperatorArity.binary)
        }
    }
    
    public func functionTokenToNode(_ function : Token<ShuntingYardTokenType>, args : [Expression]) throws -> Expression {
        if let f = functions[function.value] {
            let arity = f.arity
            switch(arity) {
            case .fix(let count) where count == args.count:
                return .call(f.init(), args)
            case .variadic where args.count > 0:
                return .call(f.init(), args)
            default:
                throw ShuntingYardError.unknownFunction(token: function, parameters: args.count)
            }
        } else {
            throw ShuntingYardError.unknownFunction(token: function, parameters: args.count)
        }
    }
    
    public func hasBinaryOperator(_ op : Token<ShuntingYardTokenType>) -> Bool {
        return binaryOperators.keys.contains(op.value)
    }
    
    public func hasUnaryOperator(_ op : Token<ShuntingYardTokenType>) -> Bool {
        return unaryOperators.keys.contains(op.value)
    }
    
    public func hasFunctionOfName(_ function : Token<ShuntingYardTokenType>) -> Bool {
        return functions.keys.contains(function.value)
    }
    
    public func hasConstantOfName(_ token : Token<ShuntingYardTokenType>) -> Bool {
        return constants.keys.contains(token.value)
    }
    
    public func literalTokenToNode(_ token : Token<ShuntingYardTokenType>) throws -> Expression {
        
        if token.value == "true" {
            return Expression.constant(Value.boolValue(value: true))
        } else if token.value == "false" {
            return Expression.constant(Value.boolValue(value: false))
        } else if let range = token.value.range(of: "\\A\"([^\"]*)\"\\Z", options: .regularExpression) {
            let string = token.value[range]
            let subString = string[string.index(after: string.startIndex)..<string.index(before: string.endIndex)]
            
            return Expression.constant(Value.stringValue(value: String(subString)))
        } else if let range = token.value.range(of: "\\A#[0-9a-z]{6}\\Z", options: .regularExpression) {
            
            let string = String(token.value[range].dropFirst())
            
            
            let digits = string.utf16.map(parseHexDigits)
            
            if let r1 = digits[0],
               let r2 = digits[1],
               let g1 = digits[2],
               let g2 = digits[3],
               let b1 = digits[4],
               let b2 = digits[5] {
                    let r = r1<<4 | r2
                    let g = g1<<4 | g2
                    let b = b1<<4 | b2
                    return Expression.constant(Value.colorValue(r: r, g:g,  b: b, a: 255))
            } else {
                throw ShuntingYardError.unexpectedToken(token: token, message: "")
            }
        } else if let range = token.value.range(of: "\\A#[0-9a-z]{8}\\Z", options: .regularExpression) {
            
            let string = String(token.value[range].dropFirst())
            
            
            let digits = string.utf16.map(parseHexDigits)
            
            if let r1 = digits[0],
                let r2 = digits[1],
                let g1 = digits[2],
                let g2 = digits[3],
                let b1 = digits[4],
                let b2 = digits[5],
                let a1 = digits[6],
                let a2 = digits[7] {
                    let r = r1<<4 | r2
                    let g = g1<<4 | g2
                    let b = b1<<4 | b2
                    let a = a1<<4 | a2
                    return Expression.constant(Value.colorValue(r: r, g:g,  b: b, a: a))
            } else {
                throw ShuntingYardError.unexpectedToken(token: token, message: "")
            }
        } else if let int = Int(token.value) {
            return Expression.constant(Value.intValue(value: int))
        } else if let double = Double(token.value) {
            return Expression.constant(Value.doubleValue(value: double))
        } else {
            throw ShuntingYardError.unexpectedToken(token: token, message: "")
        }
    }
    
    private func parseHexDigits(_ char: UTF16.CodeUnit) -> UInt8? {
        let zero = 0x30
        let nine = 0x39
        let lowerA = 0x61
        let lowerF = 0x66
        let upperA = 0x41
        let upperF = 0x46
        
        let value = Int(char)
        switch (value) {
        case zero...nine:
            return UInt8(value - zero)
        case lowerA...lowerF:
            return UInt8(value - lowerA + 10)
        case upperA...upperF:
            return UInt8(value - upperA + 10)
        default:
            return nil
        }
    }
    
    public func assocOfOperator(_ token : Token<ShuntingYardTokenType>) -> Associativity? {
        return binaryOperators[token.value]?.associativity
    }
    
    public func precedenceOfOperator(_ token : Token<ShuntingYardTokenType>, unary : Bool) -> Precedence? {
        if(unary) {
            return unaryOperators[token.value]?.precedence
        } else {
            return binaryOperators[token.value]?.precedence
        }
    }
    
    func uniqueNameFor(_ wantedName: String, definition: Definition? = nil) -> String {
        
        var testName = wantedName
        var postfix = 0
        var otherDef = sheet.definitionWithName(testName)
        
        while (otherDef?.id != nil && otherDef?.id != definition?.id || functions.keys.contains(testName) || constants.keys.contains(testName))
        {
            postfix += 1
            testName = "\(wantedName)\(postfix)"
            otherDef = sheet.definitionWithName(testName)
        }
        
        if (postfix > 0)
        {
            return testName
        }
        else
        {
            return wantedName
        }
    }
}


