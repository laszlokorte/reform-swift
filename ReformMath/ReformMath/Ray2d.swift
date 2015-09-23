//
//  Ray2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 21.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Ray2d : Equatable {
    public let from: Vec2d
    public let direction: Vec2d

    public init?(from: Vec2d, direction: Vec2d) {
        guard let dir = normalize(direction) else {
            return nil
        }
        self.from = from
        self.direction = dir
    }

    public init(from: Vec2d, angle: Angle) {
        self.from = from
        self.direction = Vec2d(radius: 1, angle: angle)
    }
}

public func ==(lhs: Ray2d, rhs: Ray2d) -> Bool {
    return lhs.from == rhs.from && lhs.direction == rhs.direction
}

extension Ray2d {
    public var angle : Angle {
        return ReformMath.angle(direction)
    }
}