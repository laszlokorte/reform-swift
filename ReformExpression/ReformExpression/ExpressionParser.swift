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
    
    let matchingPairs : [String:String] = ["(":")"]
    
    public func isMatchingPair(left : Token<ShuntingYardTokenType>, right : Token<ShuntingYardTokenType>) -> Bool {
        return matchingPairs[left.value] == right.value
    }
    public func variableTokenToNode(token : Token<ShuntingYardTokenType>) throws -> Expression {
        if let definition = sheet.definitionWithName(token.value) {
            return .Reference(id: definition.id)
        } else {
            throw ShuntingYardError.UnexpectedToken(token: token, message: "unknown identifier")
        }
    }
    
    public func constantTokenToNode(token : Token<ShuntingYardTokenType>) throws -> Expression {
        if let val = constants[token.value] {
            return Expression.NamedConstant(token.value, val)
        } else {
            throw ShuntingYardError.UnexpectedToken(token: token, message: "")
        }
    }
    
    public func emptyNode() throws -> Expression {
        return Expression.Constant(.IntValue(value: 0))
    }
    
    public func unaryOperatorToNode(op : Token<ShuntingYardTokenType>, operand : Expression) throws -> Expression {
        if let o = unaryOperators[op.value] {
            return Expression.Unary(o.op.init(), operand)
        } else {
            throw ShuntingYardError.UnknownOperator(token: op, arity: OperatorArity.Unary)
        }
    }
    
    public func binaryOperatorToNode(op : Token<ShuntingYardTokenType>, leftHand : Expression, rightHand : Expression) throws -> Expression {
        
        if let o = binaryOperators[op.value] {
            return Expression.Binary(o.op.init(), leftHand, rightHand)
        } else {
            throw ShuntingYardError.UnknownOperator(token: op, arity: OperatorArity.Binary)
        }
    }
    
    public func functionTokenToNode(function : Token<ShuntingYardTokenType>, args : [Expression]) throws -> Expression {
        if let f = functions[function.value] {
            let arity = f.arity
            switch(arity) {
            case .Fix(let count) where count == args.count:
                return .Call(f.init(), args)
            case .Variadic where args.count > 0:
                return .Call(f.init(), args)
            default:
                throw ShuntingYardError.UnknownFunction(token: function, parameters: args.count)
            }
        } else {
            throw ShuntingYardError.UnknownFunction(token: function, parameters: args.count)
        }
    }
    
    public func hasBinaryOperator(op : Token<ShuntingYardTokenType>) -> Bool {
        return binaryOperators.keys.contains(op.value)
    }
    
    public func hasUnaryOperator(op : Token<ShuntingYardTokenType>) -> Bool {
        return unaryOperators.keys.contains(op.value)
    }
    
    public func hasFunctionOfName(function : Token<ShuntingYardTokenType>) -> Bool {
        return functions.keys.contains(function.value)
    }
    
    public func hasConstantOfName(token : Token<ShuntingYardTokenType>) -> Bool {
        return constants.keys.contains(token.value)
    }
    
    public func literalTokenToNode(token : Token<ShuntingYardTokenType>) throws -> Expression {
        
        if token.value == "true" {
            return Expression.Constant(Value.BoolValue(value: true))
        } else if token.value == "false" {
            return Expression.Constant(Value.BoolValue(value: false))
        } else if let range = token.value.rangeOfString("\\A\"([^\"]*)\"\\Z", options: .RegularExpressionSearch) {
            let string = token.value[range]
            let subString = string[string.startIndex.successor()..<string.endIndex.predecessor()]
            
            return Expression.Constant(Value.StringValue(value: subString))
        } else if let range = token.value.rangeOfString("\\A#[0-9a-z]{6}\\Z", options: .RegularExpressionSearch) {
            
            let string = String(token.value[range].characters.dropFirst())
            
            
            let digits = string.utf16.map(parseHexDigits)
            
            if let r1 = digits[0],
                    r2 = digits[1],
                    g1 = digits[2],
                    g2 = digits[3],
                    b1 = digits[4],
                    b2 = digits[5] {
                    let r = r1<<4 | r2
                    let g = g1<<4 | g2
                    let b = b1<<4 | b2
                    return Expression.Constant(Value.ColorValue(r: r, g:g,  b: b, a: 255))
            } else {
                throw ShuntingYardError.UnexpectedToken(token: token, message: "")
            }
        } else if let range = token.value.rangeOfString("\\A#[0-9a-z]{8}\\Z", options: .RegularExpressionSearch) {
            
            let string = String(token.value[range].characters.dropFirst())
            
            
            let digits = string.utf16.map(parseHexDigits)
            
            if let r1 = digits[0],
                    r2 = digits[1],
                    g1 = digits[2],
                    g2 = digits[3],
                    b1 = digits[4],
                    b2 = digits[5],
                    a1 = digits[6],
                    a2 = digits[7] {
                    let r = r1<<4 | r2
                    let g = g1<<4 | g2
                    let b = b1<<4 | b2
                    let a = a1<<4 | a2
                    return Expression.Constant(Value.ColorValue(r: r, g:g,  b: b, a: a))
            } else {
                throw ShuntingYardError.UnexpectedToken(token: token, message: "")
            }
        } else if let int = Int(token.value) {
            return Expression.Constant(Value.IntValue(value: int))
        } else if let double = Double(token.value) {
            return Expression.Constant(Value.DoubleValue(value: double))
        } else {
            throw ShuntingYardError.UnexpectedToken(token: token, message: "")
        }
    }
    
    private func parseHexDigits(char: UTF16.CodeUnit) -> UInt8? {
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
    
    public func assocOfOperator(token : Token<ShuntingYardTokenType>) -> Associativity? {
        return binaryOperators[token.value]?.associativity
    }
    
    public func precedenceOfOperator(token : Token<ShuntingYardTokenType>, unary : Bool) -> Precedence? {
        if(unary) {
            return unaryOperators[token.value]?.precedence
        } else {
            return binaryOperators[token.value]?.precedence
        }
    }
    
    func uniqueNameFor(wantedName: String, definition: Definition? = nil) -> String {
        
        var testName = wantedName
        var postfix = 0
        var otherDef = sheet.definitionWithName(testName)
        
        while (otherDef?.id != nil && otherDef?.id != definition?.id || functions.keys.contains(testName) || constants.keys.contains(testName))
        {
            testName = "\(wantedName)\(++postfix)"
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


