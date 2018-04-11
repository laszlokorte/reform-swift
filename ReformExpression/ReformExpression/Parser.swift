//
//  Precedence.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 08.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Precedence : Comparable {
    fileprivate let value : Int8
    
    public init(_ value : Int8) {
        self.value = value
    }
}

public func <(lhs: Precedence, rhs: Precedence) -> Bool {
    return lhs.value < rhs.value
}

public func ==(lhs: Precedence, rhs: Precedence) -> Bool {
    return lhs.value == rhs.value
}


public enum OperatorArity {
    case binary
    case unary
}

public enum Associativity {
    case left
    case right
}

public protocol Parser {
    associatedtype NodeType
    associatedtype TokenType
    associatedtype ParseErrorType : Error
    
    func parse<T : Sequence>(_ tokens: T) -> Result<NodeType, ParseErrorType> where T.Iterator.Element==TokenType
}
