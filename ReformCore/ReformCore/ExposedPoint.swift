//
//  ExposedPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct ExposedPointIdentifier : Hashable {
    public typealias IntegerLiteralType = Int8
    
    private let id : Int
    
    init(_ id : Int) {
        self.id = id
    }
    public var hashValue : Int { return Int(id) }
}

extension ExposedPointIdentifier : IntegerLiteralConvertible, RawRepresentable {
    
    public init?(rawValue: Int) {
        self.id = rawValue
    }
    
    public var rawValue: Int {
        return id
    }
    
    public init(integerLiteral value: Int8) {
        self.id = Int(value)
    }

}

public func ==(lhs: ExposedPointIdentifier, rhs: ExposedPointIdentifier) -> Bool {
    return lhs.id == rhs.id
}

struct ExposedPoint : RuntimePoint, Labeled {
    private let point : RuntimePoint
    private let name : String
    
    init(point:RuntimePoint, name: String) {
        self.point = point
        self.name = name
    }
    
    func getPositionFor(runtime: Runtime) -> Vec2d? {
        return point.getPositionFor(runtime)
    }
    
    func getDescription(analyzer: Analyzer) -> String {        
        return name
    }
}