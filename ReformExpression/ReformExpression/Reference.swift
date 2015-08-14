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
    let id : Int
    
    init(_ id: Int) {
        self.id = id
    }
    
    public var hashValue : Int { return id }
}