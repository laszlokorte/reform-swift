//
//  LineSegment2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 21.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct LineSegment2d : Equatable {
    public let from: Vec2d
    public let to: Vec2d

    public init(from: Vec2d, to: Vec2d) {
        self.from = from
        self.to = to
    }
}

public func ==(lhs: LineSegment2d, rhs: LineSegment2d) -> Bool {
    return lhs.from == rhs.from && lhs.to == rhs.to
}

extension LineSegment2d {
    public var length : Double {
        return (to-from).length
    }
}