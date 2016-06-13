//
//  Parser.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//



public enum ShuntingYardTokenType : TokenType {
    case EOF
    case literalValue
    case argumentSeparator
    case identifier
    case parenthesisLeft
    case parenthesisRight
    case `operator`
    case Ignore
    case Unknown
    
    public static let unknown = ShuntingYardTokenType.Unknown
    public static let ignore = ShuntingYardTokenType.Ignore
    public static let eof = ShuntingYardTokenType.EOF
}


public final class ShuntingYardParser<Delegate : ShuntingYardDelegate> : Parser {
    public typealias NodeType = Delegate.NodeType
    public typealias TokenType = Token<ShuntingYardTokenType>
    
    let delegate : Delegate
    
    public init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    public func parse<T : Sequence where T.Iterator.Element==TokenType>(_ tokens: T) -> Result<NodeType, ShuntingYardError> {

        do {
            let context = ShuntingYardContext<NodeType>()
            var needOpen = false
            
            outer:
            for token in tokens
            {
                if (needOpen && token.type != .parenthesisLeft)
                {
                    throw ShuntingYardError.unexpectedToken(token: token, message: "Expected Opening Parenthesis.")
                }
                needOpen = false
                switch (token.type)
                {
                case .EOF:
                    break outer
                case .Unknown:
                    throw ShuntingYardError.unexpectedToken(token: token, message: "")
                    
                case .identifier:
                    if (context.lastTokenAtom)
                    {
                        throw ShuntingYardError.unexpectedToken(token: token, message: "")
                    }
                    if (delegate.hasFunctionOfName(token))
                    {
                        context.stack.push(token)
                        context.argCount.push(0)
                        
                        if (!context.wereValues.isEmpty)
                        {
                            context.wereValues.pop()
                            context.wereValues.push(true)
                        }
                        context.wereValues.push(false)
                        needOpen = true
                    }
                    else if(delegate.hasConstantOfName(token))
                    {
                        context.lastTokenAtom = true

                        context.output.push(try delegate.constantTokenToNode(token))
                        
                        if (!context.wereValues.isEmpty)
                        {
                            context.wereValues.pop()
                            context.wereValues.push(true)
                        }
                    }
                    else
                    {
                        context.lastTokenAtom = true
                        
                        context.output.push(try delegate.variableTokenToNode(token))
                        
                        if (!context.wereValues.isEmpty)
                        {
                            context.wereValues.pop()
                            context.wereValues.push(true)
                        }
                    }
                case .literalValue:
                    if (context.lastTokenAtom)
                    {
                        throw ShuntingYardError.unexpectedToken(token: token, message: "")
                    }
                    context.lastTokenAtom = true

                    context.output.push(try delegate.literalTokenToNode(token))

                    if (!context.wereValues.isEmpty)
                    {
                        context.wereValues.pop()
                        context.wereValues.push(true)
                    }
                case .argumentSeparator:
                    while let peek = context.stack.peek() where peek.type != .parenthesisLeft
                    {
                        context.stack.pop()
                        context.output.push(try _pipe(peek, context: context))
                    }
                    if (context.stack.isEmpty || context.wereValues.isEmpty)
                    {
                        throw ShuntingYardError.unexpectedToken(token: token, message: "")
                    }
                    if let wereValue = context.wereValues.pop() where wereValue,
                        let argCount = context.argCount.pop()
                    {
                        context.argCount.push(argCount + 1)
                    }
                    context.wereValues.push(true)
                    context.lastTokenAtom = false
                case .operator:
                    if (isOperator(context.prevToken) && delegate.hasUnaryOperator(
                        token))
                    {
                        if (context.lastTokenAtom)
                        {
                            throw ShuntingYardError.unexpectedToken(token: token, message: "")
                        }
                        context.unaries.insert(token)
                        context.stack.push(token)
                    }
                    else
                    {
                        
                        if let peek = context.stack.peek() where peek.type ==
                            ShuntingYardTokenType.identifier
                        {
                            context.stack.pop()

                            context.output.push(try _pipe(peek, context: context))
                        }
                        
                        while let peek = context.stack.peek() where peek.type == ShuntingYardTokenType.operator,
                            let tokenPrec = delegate.precedenceOfOperator(token, unary: context.actsAsUnary(token)),
                            let peekPrec = delegate.precedenceOfOperator(peek, unary: context.actsAsUnary(peek)) where (tokenPrec < peekPrec || (delegate.assocOfOperator(token) == Associativity.left && tokenPrec == peekPrec))
                        {
                            context.stack.pop()
                            context.output.push(try _pipe(peek, context: context))

                        }

                        context.stack.push(token)
                        context.lastTokenAtom = false
                    }
                case .parenthesisLeft:
                    if (context.lastTokenAtom)
                    {
                        throw ShuntingYardError.unexpectedToken(token: token, message: "")
                    }
                    context.stack.push(token)
                case .parenthesisRight:
                    while let peek = context.stack.peek() where !delegate.isMatchingPair(
                        peek, right: token)
                    {
                        context.stack.pop()

                        context.output.push(try _pipe(peek, context: context))
                    }

                    if (!context.stack.isEmpty)
                    {
                        context.stack.pop()
                    }
                    else
                    {
                        throw ShuntingYardError.mismatchedToken(token: token, open: false)
                    }
                    
                    if let peek = context.stack.peek() where peek.type ==
                        ShuntingYardTokenType.identifier
                    {
                        context.stack.pop()
                        
                        context.output.push(try _pipe(peek, context: context))
                    }
                case .Ignore:
                    continue
                }
                
                context.prevToken = token
            }

            return .success(try finalize(context))
        } catch let e as ShuntingYardError {
            return Result.fail(e)
        } catch {
            return Result.fail(ShuntingYardError.invalidState)
        }
    }
    
    func finalize(_ context : ShuntingYardContext<NodeType>) throws -> NodeType
    {
        while let peek = context.stack.peek()
        {
            if (peek.type == ShuntingYardTokenType.parenthesisLeft)
            {
                throw ShuntingYardError.mismatchedToken(token: peek, open: true)
            }
            if (peek.type == ShuntingYardTokenType.parenthesisRight)
            {
                throw ShuntingYardError.mismatchedToken(token: peek, open: false)
            }
            context.stack.pop()

            context.output.push(try _pipe(peek, context: context))
        }

        if let result = context.output.pop()
        {
            
            if (!context.output.isEmpty)
            {
                throw ShuntingYardError.invalidState
            }
            return result
        }
        else
        {
            return try delegate.emptyNode()
        }
    }
    
    
    func _pipe(_ op : Token<ShuntingYardTokenType>, context : ShuntingYardContext<NodeType>) throws -> NodeType
    {
        switch (op.type)
        {
        case .identifier:
            // @TODO: CLEAN UP
            guard var argCount = context.argCount.pop() else {
                throw ShuntingYardError.unexpectedToken(token: op, message: "")
            }
            var temp = [NodeType]()
        
            while argCount > 0, let peek = context.output.pop()
            {
                argCount -= 1
                temp.append(peek)
            }
            
            if let w = context.wereValues.pop() where w {
                if let peek = context.output.pop()
                {
                    temp.append(peek)
                }
                else
                {
                    throw ShuntingYardError.unexpectedEndOfArgumentList(token: op)
                }
            }
            
            return try delegate.functionTokenToNode(op, args: temp.reversed())

        case .operator:
            if (context.unaries.contains(op))
            {
            
            guard delegate.hasUnaryOperator(op) else
            {
                throw ShuntingYardError.unknownOperator(token: op, arity: OperatorArity.unary)
            }
            
            guard let operand = context.output.pop()
            else
            {
                throw ShuntingYardError.missingOperand(token: op, arity: OperatorArity.unary, missing: 1)
            }
            
            return try delegate.unaryOperatorToNode(op, operand: operand)
            }
            else
            {
                guard delegate.hasBinaryOperator(op) else
                {
                    throw ShuntingYardError.unknownOperator(token: op, arity: OperatorArity.binary)
                }
                
                guard let rightHand = context.output.pop()
                else
                {
                    throw ShuntingYardError.missingOperand(token: op, arity: OperatorArity.binary,missing: 2)
                }
                
                guard let leftHand = context.output.pop()
                else
                {
                    throw ShuntingYardError.missingOperand(token: op, arity: OperatorArity.binary,missing: 1)
                }
                
                return try delegate.binaryOperatorToNode(op, leftHand: leftHand, rightHand: rightHand)
            }
        default:
            throw ShuntingYardError.unexpectedToken(token: op, message: "")
        }
    }
    
    func isOperator(_ token : Token<ShuntingYardTokenType>?) -> Bool
    {
        if let t = token {
            return t.type == ShuntingYardTokenType.operator || t.type == ShuntingYardTokenType
                .argumentSeparator || t.type == ShuntingYardTokenType.parenthesisLeft        } else {
            return true
        }
    }
}




public enum ShuntingYardError : ErrorProtocol {
    case invalidState
    case unexpectedEndOfArgumentList(token: Token<ShuntingYardTokenType>)
    case missingOperand(token: Token<ShuntingYardTokenType>, arity: OperatorArity, missing: Int)
    case unknownOperator(token: Token<ShuntingYardTokenType>, arity: OperatorArity)
    case unknownFunction(token: Token<ShuntingYardTokenType>, parameters: Int)
    case unexpectedToken(token: Token<ShuntingYardTokenType>, message: String)
    case mismatchedToken(token: Token<ShuntingYardTokenType>, open: Bool)
}


final class ShuntingYardContext<NodeType>
{
    
    var stack : Stack<Token<ShuntingYardTokenType>> = Stack()
    var output : Stack<NodeType> = Stack<NodeType>()
    
    var wereValues : Stack<Bool> = Stack<Bool>()
    var argCount : Stack<Int>  = Stack<Int>()
    var unaries: Set<Token<ShuntingYardTokenType>>  = Set()
    
    var prevToken : Token<ShuntingYardTokenType>? = nil
    
    var lastTokenAtom : Bool = false
    
    
    func actsAsUnary(_ token : Token<ShuntingYardTokenType>) -> Bool
    {
        return unaries.contains(token)
    }
}

public protocol ShuntingYardDelegate {
    associatedtype NodeType
    
    func isMatchingPair(_ left : Token<ShuntingYardTokenType>, right : Token<ShuntingYardTokenType>) -> Bool
    
    func hasFunctionOfName(_ name : Token<ShuntingYardTokenType>) -> Bool
    
    func hasConstantOfName(_ name : Token<ShuntingYardTokenType>) -> Bool
    
    func variableTokenToNode(_ token : Token<ShuntingYardTokenType>) throws -> NodeType
    func constantTokenToNode(_ token : Token<ShuntingYardTokenType>) throws -> NodeType
    func emptyNode() throws -> NodeType
    
    func unaryOperatorToNode(_ op : Token<ShuntingYardTokenType>, operand : NodeType) throws -> NodeType
    
    func binaryOperatorToNode(_ op : Token<ShuntingYardTokenType>, leftHand : NodeType, rightHand : NodeType) throws -> NodeType
    
    func functionTokenToNode(_ function : Token<ShuntingYardTokenType>, args : [NodeType]) throws -> NodeType
    
    func hasBinaryOperator(_ op : Token<ShuntingYardTokenType>) -> Bool
    
    func hasUnaryOperator(_ op : Token<ShuntingYardTokenType>) -> Bool
    
    func assocOfOperator(_ token : Token<ShuntingYardTokenType>) -> Associativity?
    
    func precedenceOfOperator(_ token : Token<ShuntingYardTokenType>, unary : Bool) -> Precedence?
    
    func literalTokenToNode(_ token : Token<ShuntingYardTokenType>) throws -> NodeType

}
