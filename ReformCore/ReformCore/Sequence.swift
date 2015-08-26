//
//  Sequence.swift
//  ReformCore
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public protocol SequenceGeneratable {
    init(id: Int64)
}

public class IdentifierSequence<T:SequenceGeneratable> {
    var sequenceValue : Int64
    let type : T.Type
    
    public init(type: T.Type = T.self, initialValue : Int64) {
        self.sequenceValue = initialValue
        self.type = type
    }
    
    public func emitId() -> T {
        sequenceValue++
        return type.init(id: sequenceValue)
    }
}