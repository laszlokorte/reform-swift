//
//  FormIdentifier.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct FormIdentifier : Hashable {
    public let value : Int
    
    public init(_ value : Int) {
        self.value = value
    }
    
    public var hashValue : Int { return Int(value) }
}

public func ==(lhs: FormIdentifier, rhs: FormIdentifier) -> Bool {
    return lhs.value == rhs.value
}

extension FormIdentifier : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "FormId(\(value))"
    }
}

extension FormIdentifier : SequenceGeneratable {
    public init(id : Int) {
        self.init(id)
    }
}