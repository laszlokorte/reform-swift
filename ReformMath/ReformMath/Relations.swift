//
//  Relations.swift
//  ReformMath
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

func sign(_ p: Vec2d, a: Vec2d, b: Vec2d) -> Double
{
    return (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)
}

public func leftOf(_ point: Vec2d, line: Line2d, epsilon: Double = 0) -> Bool {
    return sign(point, a:line.from, b:line.from + line.direction) < epsilon
}
