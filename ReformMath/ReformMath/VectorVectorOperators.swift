//
//  VectorVectorOperators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 12.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func +(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Vec2d, rhs: Vec2d) -> Vec2d {
    return Vec2d(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public prefix func -(op: Vec2d) -> Vec2d {
    return Vec2d(x: -op.x, y: -op.y)
}