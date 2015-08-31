//
//  DataSet.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public protocol DataSet {
    func lookUp(id: ReferenceId) -> Value?
    
    func getError(id: ReferenceId) -> EvaluationError?
}

public struct ReferenceId : Hashable {
    public let value : Int
    
    public init(_ value: Int) {
        self.value = value
    }
    
    public var hashValue : Int { return value }
}