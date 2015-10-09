//
//  Parser.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//



public enum ShuntingYardTokenType : TokenType {
    case EOF
    case LiteralValue
    case ArgumentSeparator
    case Identifier
    case ParenthesisLeft
    case ParenthesisRight
    case Operator
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
    
    public func parse<T : SequenceType where T.Generator.Element==TokenType>(tokens: T) -> Result<NodeType, ShuntingYardError> {

        do {
            let context = ShuntingYardContext<NodeType>()
            var needOpen = false
            
            outer:
            for token in tokens
            {
                if (needOpen && token.type != .ParenthesisLeft)
                {
                    throw ShuntingYardError.UnexpectedToken(token: token, message: "Expected Opening Parenthesis.")
                }
                needOpen = false
                switch (token.type)
                {
                case .EOF:
                    break outer
                case .Unknown:
                    throw ShuntingYardError.UnexpectedToken(token: token, message: "")
                    
                case .Identifier:
                    if (context.lastTokenAtom)
                    {
                        throw ShuntingYardError.UnexpectedToken(token: token, message: "")
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
                case .LiteralValue:
                    if (context.lastTokenAtom)
                    {
                        throw ShuntingYardError.UnexpectedToken(token: token, message: "")
                    }
                    context.lastTokenAtom = true

                    context.output.push(try delegate.literalTokenToNode(token))

                    if (!context.wereValues.isEmpty)
                    {
                        context.wereValues.pop()
                        context.wereValues.push(true)
                    }
                case .ArgumentSeparator:
                    while let peek = context.stack.peek() where peek.type != .ParenthesisLeft
                    {
                        context.stack.pop()
                        context.output.push(try _pipe(peek, context: context))
                    }
                    if (context.stack.isEmpty || context.wereValues.isEmpty)
                    {
                        throw ShuntingYardError.UnexpectedToken(token: token, message: "")
                    }
                    if let wereValue = context.wereValues.pop() where wereValue,
                        let argCount = context.argCount.pop()
                    {
                        context.argCount.push(argCount + 1)
                    }
                    context.wereValues.push(true)
                    context.lastTokenAtom = false
                case .Operator:
                    if (isOperator(context.prevToken) && delegate.hasUnaryOperator(
                        token))
                    {
                        if (context.lastTokenAtom)
                        {
                            throw ShuntingYardError.UnexpectedToken(token: token, message: "")
                        }
                        context.unaries.insert(token)
                        context.stack.push(token)
                    }
                    else
                    {
                        
                        if let peek = context.stack.peek() where peek.type ==
                            ShuntingYardTokenType.Identifier
                        {
                            context.stack.pop()

                            context.output.push(try _pipe(peek, context: context))
                        }
                        
                        while let peek = context.stack.peek() where peek.type == ShuntingYardTokenType.Operator,
                            let tokenPrec = delegate.precedenceOfOperator(token, unary: context.actsAsUnary(token)),
                            let peekPrec = delegate.precedenceOfOperator(peek, unary: context.actsAsUnary(peek)) where (tokenPrec < peekPrec || (delegate.assocOfOperator(token) == Associativity.Left && tokenPrec == peekPrec))
                        {
                            context.stack.pop()
                            context.output.push(try _pipe(peek, context: context))

                        }

                        context.stack.push(token)
                        context.lastTokenAtom = false
                    }
                case .ParenthesisLeft:
                    if (context.lastTokenAtom)
                    {
                        throw ShuntingYardError.UnexpectedToken(token: token, message: "")
                    }
                    context.stack.push(token)
                case .ParenthesisRight:
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
                        throw ShuntingYardError.MismatchedToken(token: token, open: false)
                    }
                    
                    if let peek = context.stack.peek() where peek.type ==
                        ShuntingYardTokenType.Identifier
                    {
                        context.stack.pop()
                        
                        context.output.push(try _pipe(peek, context: context))
                    }
                case .Ignore:
                    continue
                }
                
                context.prevToken = token
            }

            return .Success(try finalize(context))
        } catch let e as ShuntingYardError {
            return Result.Fail(e)
        } catch {
            return Result.Fail(ShuntingYardError.InvalidState)
        }
    }
    
    func finalize(context : ShuntingYardContext<NodeType>) throws -> NodeType
    {
        while let peek = context.stack.peek()
        {
            if (peek.type == ShuntingYardTokenType.ParenthesisLeft)
            {
                throw ShuntingYardError.MismatchedToken(token: peek, open: true)
            }
            if (peek.type == ShuntingYardTokenType.ParenthesisRight)
            {
                throw ShuntingYardError.MismatchedToken(token: peek, open: false)
            }
            context.stack.pop()

            context.output.push(try _pipe(peek, context: context))
        }

        if let result = context.output.pop()
        {
            
            if (!context.output.isEmpty)
            {
                throw ShuntingYardError.InvalidState
            }
            return result
        }
        else
        {
            return try delegate.emptyNode()
        }
    }
    
    
    func _pipe(op : Token<ShuntingYardTokenType>, context : ShuntingYardContext<NodeType>) throws -> NodeType
    {
        switch (op.type)
        {
        case .Identifier:
            // @TODO: CLEAN UP
            guard var argCount = context.argCount.pop() else {
                throw ShuntingYardError.UnexpectedToken(token: op, message: "")
            }
            var temp = [NodeType]()
        
            while argCount-- > 0, let peek = context.output.pop()
            {
                temp.append(peek)
            }
            
            if let w = context.wereValues.pop() where w {
                if let peek = context.output.pop()
                {
                    temp.append(peek)
                }
                else
                {
                    throw ShuntingYardError.UnexpectedEndOfArgumentList(token: op)
                }
            }
            
            return try delegate.functionTokenToNode(op, args: temp.reverse())

        case .Operator:
            if (context.unaries.contains(op))
            {
            
            guard delegate.hasUnaryOperator(op) else
            {
                throw ShuntingYardError.UnknownOperator(token: op, arity: OperatorArity.Unary)
            }
            
            guard let operand = context.output.pop()
            else
            {
                throw ShuntingYardError.MissingOperand(token: op, arity: OperatorArity.Unary, missing: 1)
            }
            
            return try delegate.unaryOperatorToNode(op, operand: operand)
            }
            else
            {
                guard delegate.hasBinaryOperator(op) else
                {
                    throw ShuntingYardError.UnknownOperator(token: op, arity: OperatorArity.Binary)
                }
                
                guard let rightHand = context.output.pop()
                else
                {
                    throw ShuntingYardError.MissingOperand(token: op, arity: OperatorArity.Binary,missing: 2)
                }
                
                guard let leftHand = context.output.pop()
                else
                {
                    throw ShuntingYardError.MissingOperand(token: op, arity: OperatorArity.Binary,missing: 1)
                }
                
                return try delegate.binaryOperatorToNode(op, leftHand: leftHand, rightHand: rightHand)
            }
        default:
            throw ShuntingYardError.UnexpectedToken(token: op, message: "")
        }
    }
    
    func isOperator(token : Token<ShuntingYardTokenType>?) -> Bool
    {
        if let t = token {
            return t.type == ShuntingYardTokenType.Operator || t.type == ShuntingYardTokenType
                .ArgumentSeparator || t.type == ShuntingYardTokenType.ParenthesisLeft        } else {
            return true
        }
    }
}




public enum ShuntingYardError : ErrorType {
    case InvalidState
    case UnexpectedEndOfArgumentList(token: Token<ShuntingYardTokenType>)
    case MissingOperand(token: Token<ShuntingYardTokenType>, arity: OperatorArity, missing: Int)
    case UnknownOperator(token: Token<ShuntingYardTokenType>, arity: OperatorArity)
    case UnknownFunction(token: Token<ShuntingYardTokenType>, parameters: Int)
    case UnexpectedToken(token: Token<ShuntingYardTokenType>, message: String)
    case MismatchedToken(token: Token<ShuntingYardTokenType>, open: Bool)
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
    
    
    func actsAsUnary(token : Token<ShuntingYardTokenType>) -> Bool
    {
        return unaries.contains(token)
    }
}

public protocol ShuntingYardDelegate {
    typealias NodeType
    
    func isMatchingPair(left : Token<ShuntingYardTokenType>, right : Token<ShuntingYardTokenType>) -> Bool
    
    func hasFunctionOfName(name : Token<ShuntingYardTokenType>) -> Bool
    
    func hasConstantOfName(name : Token<ShuntingYardTokenType>) -> Bool
    
    func variableTokenToNode(token : Token<ShuntingYardTokenType>) throws -> NodeType
    func constantTokenToNode(token : Token<ShuntingYardTokenType>) throws -> NodeType
    func emptyNode() throws -> NodeType
    
    func unaryOperatorToNode(op : Token<ShuntingYardTokenType>, operand : NodeType) throws -> NodeType
    
    func binaryOperatorToNode(op : Token<ShuntingYardTokenType>, leftHand : NodeType, rightHand : NodeType) throws -> NodeType
    
    func functionTokenToNode(function : Token<ShuntingYardTokenType>, args : [NodeType]) throws -> NodeType
    
    func hasBinaryOperator(op : Token<ShuntingYardTokenType>) -> Bool
    
    func hasUnaryOperator(op : Token<ShuntingYardTokenType>) -> Bool
    
    func assocOfOperator(token : Token<ShuntingYardTokenType>) -> Associativity?
    
    func precedenceOfOperator(token : Token<ShuntingYardTokenType>, unary : Bool) -> Precedence?
    
    func literalTokenToNode(token : Token<ShuntingYardTokenType>) throws -> NodeType

}