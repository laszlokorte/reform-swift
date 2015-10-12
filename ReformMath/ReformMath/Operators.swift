//
//  Operators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

// Vector-Scalar



// Angle-Angle


// Angle-Scalar



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