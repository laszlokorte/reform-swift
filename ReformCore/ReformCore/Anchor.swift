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
    private let id : Int
    
    init(_ id : Int) {
        self.id = id
    }
    
    public var hashValue : Int { return Int(id) }
}

public func ==(lhs: AnchorIdentifier, rhs: AnchorIdentifier) -> Bool {
    return lhs.id == rhs.id
}