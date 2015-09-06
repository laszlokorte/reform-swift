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
        let context = ShuntingYardContext<NodeType>();
        var needOpen = false;
        
        outer:
        for token in tokens
        {
            if (needOpen && token.type != .ParenthesisLeft)
            {
                return .Fail(.UnexpectedToken(token: token, message: "Expected Opening Parenthesis."))
            }
            needOpen = false;
            switch (token.type)
            {
            case .EOF:
                break outer;
            case .Unknown:
                return .Fail(.UnexpectedToken(token: token, message: ""))
                
            case .Identifier:
                if (context.lastTokenAtom)
                {
                    return .Fail(.UnexpectedToken(token: token, message: ""))
                }
                if (delegate.hasFunctionOfName(token))
                {
                    context.stack.push(token);
                    context.argCount.push(0);
                    
                    if (!context.wereValues.isEmpty)
                    {
                        context.wereValues.pop();
                        context.wereValues.push(true);
                    }
                    context.wereValues.push(false);
                    needOpen = true;
                }
                else if(delegate.hasConstantOfName(token))
                {
                    context.lastTokenAtom = true;
                    
                    switch delegate.constantTokenToNode(token) {
                        case .Success(let node):
                            context.output.push(node);
                        case .Fail(let error):
                            return .Fail(error)
                    }
                    
                    if (!context.wereValues.isEmpty)
                    {
                        context.wereValues.pop();
                        context.wereValues.push(true);
                    }
                }
                else
                {
                    context.lastTokenAtom = true;
                    
                    switch delegate.variableTokenToNode(token) {
                    case .Success(let node):
                        context.output.push(node);
                    case .Fail(let error):
                        return .Fail(error)
                    }
                    
                    if (!context.wereValues.isEmpty)
                    {
                        context.wereValues.pop();
                        context.wereValues.push(true);
                    }
                }
            case .LiteralValue:
                if (context.lastTokenAtom)
                {
                    return .Fail(.UnexpectedToken(token: token, message: ""))
                }
                context.lastTokenAtom = true;
                
                switch delegate.literalTokenToNode(token) {
                case .Success(let node):
                    context.output.push(node);
                case .Fail(let error):
                    return .Fail(error)
                }
                
                if (!context.wereValues.isEmpty)
                {
                    context.wereValues.pop();
                    context.wereValues.push(true);
                }
            case .ArgumentSeparator:
                while let peek = context.stack.peek() where peek.type != .ParenthesisLeft
                {
                    context.stack.pop()
                    switch _pipe(peek, context: context) {
                    case .Success(let node):
                        context.output.push(node);
                    case .Fail(let error):
                        return .Fail(error)
                    }
                }
                if (context.stack.isEmpty || context.wereValues.isEmpty)
                {
                    return .Fail(.UnexpectedToken(token: token, message: ""))
                }
                if let wereValue = context.wereValues.pop() where wereValue,
                    let argCount = context.argCount.pop()
                {
                    context.argCount.push(argCount + 1);
                }
                context.wereValues.push(true)
                context.lastTokenAtom = false
            case .Operator:
                if (isOperator(context.prevToken) && delegate.hasUnaryOperator(
                    token))
                {
                    if (context.lastTokenAtom)
                    {
                        return .Fail(.UnexpectedToken(token: token, message: ""))
                    }
                    context.unaries.insert(token);
                    context.stack.push(token);
                }
                else
                {
                    
                    if let peek = context.stack.peek() where peek.type ==
                        ShuntingYardTokenType.Identifier
                    {
                        context.stack.pop()
                        switch _pipe(peek, context: context) {
                        case .Success(let node):
                            context.output.push(node);
                        case .Fail(let error):
                            return .Fail(error)
                        }
                    }
                    
                    while let peek = context.stack.peek() where peek.type == ShuntingYardTokenType.Operator,
                        let tokenPrec = delegate.precedenceOfOperator(token, unary: context.actsAsUnary(token)),
                        let peekPrec = delegate.precedenceOfOperator(peek, unary: context.actsAsUnary(peek)) where (tokenPrec < peekPrec || (delegate.assocOfOperator(token) == Associativity.Left && tokenPrec == peekPrec))
                    {
                        context.stack.pop()
                        switch _pipe(peek, context: context) {
                        case .Success(let node):
                            context.output.push(node);
                        case .Fail(let error):
                            return .Fail(error)
                        }
                    }
                    
                    context.stack.push(token);
                    context.lastTokenAtom = false;
                }
            case .ParenthesisLeft:
                if (context.lastTokenAtom)
                {
                    return .Fail(.UnexpectedToken(token: token, message: ""))
                }
                context.stack.push(token);
            case .ParenthesisRight:
                while let peek = context.stack.peek() where !delegate.isMatchingPair(
                    peek, right: token)
                {
                    context.stack.pop()
                    switch _pipe(peek, context: context) {
                    case .Success(let node):
                        context.output.push(node);
                    case .Fail(let error):
                        return .Fail(error)
                    }
                }
                
                if (!context.stack.isEmpty)
                {
                    context.stack.pop();
                }
                else
                {
                    return .Fail(.MismatchedToken(token: token, open: false))
                }
                
                if let peek = context.stack.peek() where peek.type ==
                    ShuntingYardTokenType.Identifier
                {
                    context.stack.pop()
                    
                    switch _pipe(peek, context: context) {
                    case .Success(let node):
                        context.output.push(node);
                    case .Fail(let error):
                        return .Fail(error)
                    }
                }
            case .Ignore:
                continue
            }
            
            context.prevToken = token;
        }
        
        return finalize(context);
    }
    
    func finalize(context : ShuntingYardContext<NodeType>) -> Result<NodeType, ShuntingYardError>
    {
        while let peek = context.stack.peek()
        {
            if (peek.type == ShuntingYardTokenType.ParenthesisLeft)
            {
                return .Fail(.MismatchedToken(token: peek, open: true))
            }
            if (peek.type == ShuntingYardTokenType.ParenthesisRight)
            {
                return .Fail(.MismatchedToken(token: peek, open: false))
            }
            context.stack.pop()
            switch _pipe(peek, context: context) {
            case .Success(let node):
                context.output.push(node);
            case .Fail(let error):
                return .Fail(error)
            }
        }
        
        if let result = context.output.pop()
        {
            
            if (!context.output.isEmpty)
            {
                return .Fail(.InvalidState)
            }
            return .Success(result);
        }
        else
        {
            return delegate.emptyNode();
        }
    }
    
    
    func _pipe(op : Token<ShuntingYardTokenType>, context : ShuntingYardContext<NodeType>) -> Result<NodeType, ShuntingYardError>
    {
        switch (op.type)
        {
        case .Identifier:
            // @TODO: CLEAN UP
            guard var argCount = context.argCount.pop() else {
                return .Fail(.UnexpectedToken(token: op, message: ""))
            }
            var temp = [NodeType]();
        
            while argCount-- > 0, let peek = context.output.pop()
            {
                temp.append(peek);
            }
            
            if let w = context.wereValues.pop() where w {
                if let peek = context.output.pop()
                {
                    temp.append(peek);
                }
                else
                {
                    return .Fail(.UnexpectedEndOfArgumentList(token: op))
                }
            }
            
            return delegate.functionTokenToNode(op, args: temp.reverse());

        case .Operator:
            if (context.unaries.contains(op))
            {
            
            guard delegate.hasUnaryOperator(op) else
            {
                return .Fail(.UnknownOperator(token: op, arity: OperatorArity.Unary))
            }
            
            guard let operand = context.output.pop()
            else
            {
                return .Fail(.MissingOperand(token: op, arity: OperatorArity.Unary, missing: 1))
            }
            
            return delegate.unaryOperatorToNode(op, operand: operand);
            }
            else
            {
                guard delegate.hasBinaryOperator(op) else
                {
                    return .Fail(.UnknownOperator(token: op, arity: OperatorArity.Binary))
                }
                
                guard let rightHand = context.output.pop()
                else
                {
                    return .Fail(.MissingOperand(token: op, arity: OperatorArity.Binary,missing: 2))
                }
                
                guard let leftHand = context.output.pop()
                else
                {
                    return .Fail(.MissingOperand(token: op, arity: OperatorArity.Binary,missing: 1))
                }
                
                return delegate.binaryOperatorToNode(op, leftHand: leftHand, rightHand: rightHand);
            }
        default:
            return .Fail(.UnexpectedToken(token: op, message: ""))
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
    
    var stack : Stack<Token<ShuntingYardTokenType>> = Stack();
    var output : Stack<NodeType> = Stack<NodeType>();
    
    var wereValues : Stack<Bool> = Stack<Bool>();
    var argCount : Stack<Int>  = Stack<Int>();
    var unaries: Set<Token<ShuntingYardTokenType>>  = Set();
    
    var prevToken : Token<ShuntingYardTokenType>? = nil;
    
    var lastTokenAtom : Bool = false;
    
    
    func actsAsUnary(token : Token<ShuntingYardTokenType>) -> Bool
    {
        return unaries.contains(token);
    }
}

public protocol ShuntingYardDelegate {
    typealias NodeType
    
    func isMatchingPair(left : Token<ShuntingYardTokenType>, right : Token<ShuntingYardTokenType>) -> Bool
    
    func hasFunctionOfName(name : Token<ShuntingYardTokenType>) -> Bool
    
    func hasConstantOfName(name : Token<ShuntingYardTokenType>) -> Bool
    
    func variableTokenToNode(token : Token<ShuntingYardTokenType>) -> Result<NodeType, ShuntingYardError>
    
    func constantTokenToNode(token : Token<ShuntingYardTokenType>) -> Result<NodeType, ShuntingYardError>
    
    func emptyNode() -> Result<NodeType, ShuntingYardError>
    
    func unaryOperatorToNode(op : Token<ShuntingYardTokenType>, operand : NodeType) -> Result<NodeType, ShuntingYardError>
    
    func binaryOperatorToNode(op : Token<ShuntingYardTokenType>, leftHand : NodeType, rightHand : NodeType) -> Result<NodeType, ShuntingYardError>
    
    func functionTokenToNode(function : Token<ShuntingYardTokenType>, args : [NodeType]) -> Result<NodeType, ShuntingYardError>
    
    func hasBinaryOperator(op : Token<ShuntingYardTokenType>) -> Bool
    
    func hasUnaryOperator(op : Token<ShuntingYardTokenType>) -> Bool
    
    func assocOfOperator(token : Token<ShuntingYardTokenType>) -> Associativity?
    
    func precedenceOfOperator(token : Token<ShuntingYardTokenType>, unary : Bool) -> Precedence?
    
    func literalTokenToNode(token : Token<ShuntingYardTokenType>) -> Result<NodeType, ShuntingYardError>

}