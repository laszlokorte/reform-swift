//
//  Operators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation

public func +(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x + rhs.x, y: lhs.x + rhs.x)
}

public func -(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x - rhs.x, y: lhs.x - rhs.x)
}

public func *(lhs: Vec2d, rhs: Double) -> Vec2d {
    return Vec2d(x: lhs.x * rhs, y: lhs.x * rhs)
}

public func *(lhs: Double, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs * rhs.x, y: lhs * rhs.x)
}

public func /(lhs: Vec2d, rhs: Double) -> Vec2d {
    return Vec2d(x: lhs.x / rhs, y: lhs.x / rhs)
}


public func +(lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians + rhs.radians)
}

public func -(lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians - rhs.radians)
}

public prefix func -(op: Angle) -> Angle {
    return Angle(radians: -op.radians)
}

public prefix func -(op: Vec2d) -> Vec2d {
    return Vec2d(x: -op.x, y: -op.y)
}