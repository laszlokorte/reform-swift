//
//  HitArea.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public enum HitArea {
    case None
    case Line(a: Vec2d, b: Vec2d)
    case Triangle(a: Vec2d, b: Vec2d, c: Vec2d)
    case Circle(center: Vec2d, radius: Double)
    case LeftOf(a: Vec2d, b: Vec2d)
    indirect case Union(HitArea, HitArea)
    indirect case Intersection(HitArea, HitArea)
    indirect case Inversion(HitArea)
}

extension HitArea {
    public func contains(point: Vec2d) -> Bool {
        switch self {
        case None:
            return false
        case .Line(let a, let b):
            return onLineSegment(point, lineSegment: LineSegment2d(from: a, to:b), epsilon: 2)
        case .Circle(let center, let radius):
            return (point-center).length < radius
        case Triangle(let a, let b, let c):
            return inTriangle(point, triangle: (a,b,c))
        case LeftOf(let a, let b):
            return leftOf(point, lineSegment: LineSegment2d(from: a, to:b))
        case .Union(let a, let b):
            return a.contains(point) || b.contains(point)
        case .Intersection(let a, let b):
            return a.contains(point) && b.contains(point)
        case Inversion(let area):
            return !area.contains(point)
        }
    }
}