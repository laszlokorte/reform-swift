//
//  Precedence.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 08.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Precedence : Comparable {
    private let value : Int8
    
    init(_ value : Int8) {
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
    case Binary
    case Unary
}

public enum Associativity {
    case Left
    case Right
}

public protocol Parser {
    typealias NodeType
    typealias TokenType
    typealias ParseErrorType : ErrorType
    
    func parse<T : SequenceType where T.Generator.Element==TokenType>(tokens: T) -> Result<NodeType, ParseErrorType>
}