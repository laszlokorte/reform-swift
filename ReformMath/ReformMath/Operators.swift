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


// Mat3x2-Mat3x2

public func *(lhs: Mat3x2, rhs: Mat3x2) -> Mat3x2 {
    let col1 = Vec2d(
        x: lhs.col1.x * rhs.col1.x + lhs.col2.x * rhs.col1.y,
        y: lhs.col1.y * rhs.col1.x + lhs.col2.y * rhs.col1.y
    )

    let col2 = Vec2d(
        x: lhs.col1.x * rhs.col2.x + lhs.col2.x * rhs.col2.y,
        y: lhs.col1.y * rhs.col2.x + lhs.col2.y * rhs.col2.y
    )

    let col3 = Vec2d(
        x: lhs.col1.x * rhs.col3.x + lhs.col2.x * rhs.col3.y
            + lhs.col3.x,
        y: lhs.col1.y * rhs.col3.x + lhs.col2.y * rhs.col3.y
            + lhs.col3.y
    )

    return Mat3x2(col1: col1, col2: col2, col3: col3)
}


// Mat3x2-Vec2d

public func *(lhs: Mat3x2, rhs: Vec2d) -> Vec2d {
    return Vec2d(
        x: lhs.col1.x * rhs.x + lhs.col2.x * rhs.y + lhs.col3.x,
        y: lhs.col1.y * rhs.x + lhs.col2.y * rhs.y + lhs.col3.y
    )
}