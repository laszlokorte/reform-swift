//
//  Containment.swift
//  ReformMath
//
//  Created by Laszlo Korte on 22.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func inside(point: Vec2d, circle: Circle2d, epsilon: Double = 0) -> Bool
{
    return distance(point: point, point: circle.center) < circle.radius + epsilon
}

public func inside(point: Vec2d, arc: Arc2d, epsilon: Double = 0) -> Bool
{
    return distance(point: point, point: arc.center) < arc.radius + epsilon && isBetween(angle(point-arc.center), lower: arc.start, upper: arc.end)
}

public func inside(point : Vec2d, triangle: Triangle2d, epsilon : Double = 0) -> Bool
{
    let b1 = sign(point, a:triangle.a, b:triangle.b) < epsilon
    let b2 = sign(point, a:triangle.b, b:triangle.c) < epsilon
    let b3 = sign(point, a:triangle.c, b:triangle.a) < epsilon

    return b1 == b2 && b2 == b3;
}


public func inside(point: Vec2d, aabb: AABB2d, epsilon: Double = 0) -> Bool {
    return aabb.outCode(point, epsilon: epsilon) == .Inside
}