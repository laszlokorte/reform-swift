//
//  FormIdentifier.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct FormIdentifier : Hashable {
    private let id : Int64
    
    public init(_ id : Int64) {
        self.id = id
    }
    
    public var hashValue : Int { return Int(id) }
}

public func ==(lhs: FormIdentifier, rhs: FormIdentifier) -> Bool {
    return lhs.id == rhs.id
}

extension FormIdentifier : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "FormId(\(id))"
    }
}