//
//  Relations.swift
//  ReformMath
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func distance(point pointA: Vec2d, point pointB: Vec2d) -> Double {
    return (pointB - pointA).length
}

func sign(p: Vec2d, a: Vec2d, b: Vec2d) -> Double
{
    return (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)
}

public func inTriangle(p : Vec2d, triangle: (a: Vec2d, b: Vec2d, c: Vec2d)) -> Bool
{
    let b1 = sign(p, a:triangle.a, b:triangle.b) < 0
    let b2 = sign(p, a:triangle.b, b:triangle.c) < 0
    let b3 = sign(p, a:triangle.c, b:triangle.a) < 0

    return b1 == b2 && b2 == b3;
}

public func leftOf(point: Vec2d, lineSegment: LineSegment2d) -> Bool {
    return sign(point, a:lineSegment.to, b:lineSegment.from) < 0
}


public func onLineSegment(point: Vec2d, lineSegment: LineSegment2d, epsilon: Double = EPSILON) -> Bool
{
    let delta = (point - lineSegment.from).length + (point - lineSegment.to).length - lineSegment.length

    return -epsilon < delta && delta < epsilon
}


public func inside(point: Vec2d, aabb: AABB2d) -> Bool {
    return aabb.outCode(point) == .Inside
}
