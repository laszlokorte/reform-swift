//
//  Incidence.swift
//  ReformMath
//
//  Created by Laszlo Korte on 24.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func incident(_ point: Vec2d, lineSegment: LineSegment2d, epsilon: Double = .EPSILON) -> Bool
{
    let delta = (point - lineSegment.from).length + (point - lineSegment.to).length - lineSegment.length

    return -epsilon < delta && delta < epsilon
}

public func incident(_ point: Vec2d, arc: Arc2d, epsilon: Double = .EPSILON) -> Bool
{
    // TODO: implement
    return false
}
