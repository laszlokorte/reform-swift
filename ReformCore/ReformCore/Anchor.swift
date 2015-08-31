//
//  Anchor.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Anchor {
    func getPositionFor(runtime: Runtime) -> Vec2d?
    
    func translate(runtime: Runtime, delta: Vec2d)
    
    var name : String { get }
}

public struct AnchorIdentifier : Hashable {
    public let value : Int
    
    public init(_ value : Int) {
        self.value = value
    }
    
    public var hashValue : Int { return value }
}

public func ==(lhs: AnchorIdentifier, rhs: AnchorIdentifier) -> Bool {
    return lhs.value == rhs.value
}

extension AnchorIdentifier : IntegerLiteralConvertible, RawRepresentable {
    
    public init?(rawValue: Int) {
        self.value = rawValue
    }
    
    public var rawValue: Int {
        return value
    }
    
    public init(integerLiteral value: Int8) {
        self.value = Int(value)
    }
    
}