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

public func leftOf(point: Vec2d, ray: Ray2d, epsilon: Double = 0) -> Bool {
    return sign(point, a:ray.from, b:ray.from + ray.direction) < epsilon
}


public func onLineSegment(point: Vec2d, lineSegment: LineSegment2d, epsilon: Double = EPSILON) -> Bool
{
    let delta = (point - lineSegment.from).length + (point - lineSegment.to).length - lineSegment.length

    return -epsilon < delta && delta < epsilon
}
