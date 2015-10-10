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
    
    public let value : Int
    
    public init(_ value : Int) {
        self.value = value
    }
    public var hashValue : Int { return Int(value) }
}

extension ExposedPointIdentifier : IntegerLiteralConvertible, RawRepresentable {
    
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

public func ==(lhs: ExposedPointIdentifier, rhs: ExposedPointIdentifier) -> Bool {
    return lhs.value == rhs.value
}

struct ExposedPoint : RuntimePoint, Labeled {
    private let point : RuntimePoint
    private let name : String
    
    init(point:RuntimePoint, name: String) {
        self.point = point
        self.name = name
    }
    
    func getPositionFor<R:Runtime>(runtime: R) -> Vec2d? {
        return point.getPositionFor(runtime)
    }
    
    func getDescription(stringifier: Stringifier) -> String {
        return name
    }
}

extension ExposedPoint : Equatable {

}

func ==(lhs: ExposedPoint, rhs: ExposedPoint) -> Bool {
    return lhs.point.isEqualTo(rhs.point)
}