//
//  Operators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation

// Vector-Vector

public func +(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public prefix func -(op: Vec2d) -> Vec2d {
    return Vec2d(x: -op.x, y: -op.y)
}


// Vector-Scalar

public func +(lhs: Vec2d, rhs: Double) -> Vec2d {
    return Vec2d(x: lhs.x + rhs, y: lhs.y + rhs)
}

public func -(lhs: Vec2d, rhs: Double) -> Vec2d {
    return Vec2d(x: lhs.x - rhs, y: lhs.y - rhs)
}


public func +(lhs: Double, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs + rhs.x, y: lhs + rhs.y)
}
public func -(lhs: Double, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs - rhs.x, y: lhs - rhs.y)
}

public func *(lhs: Vec2d, rhs: Double) -> Vec2d {
    return Vec2d(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func *(lhs: Double, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs * rhs.x, y: lhs * rhs.y)
}

public func *(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

public func /(lhs: Vec2d, rhs: Double) -> Vec2d {
    return Vec2d(x: lhs.x / rhs, y: lhs.y / rhs)
}

public func /(lhs: Double, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs / rhs.x, y: lhs / rhs.y)
}



// Angle-Angle

public func +(lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians + rhs.radians)
}

public func -(lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians - rhs.radians)
}

public prefix func -(op: Angle) -> Angle {
    return Angle(radians: -op.radians)
}

public func /(lhs: Angle, rhs: Angle) -> Double {
    return lhs.radians / rhs.radians
}


// Angle-Scalar

public func *(lhs: Angle, rhs: Double) -> Angle {
    return Angle(radians: lhs.radians * rhs)
}

public func *(lhs: Double, rhs: Angle) -> Angle {
    return Angle(radians: lhs * rhs.radians)
}

public func /(lhs: Angle, rhs: Double) -> Angle {
    return Angle(radians: lhs.radians / rhs)
}