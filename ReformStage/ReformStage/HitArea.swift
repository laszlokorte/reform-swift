//
//  HitArea.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public enum HitArea : Equatable {
    case None
    case Line(LineSegment2d)
    case Triangle(Triangle2d)
    case Circle(Circle2d)
    case Arc(Arc2d)
    case Sector(center: Vec2d, lower: Angle, upper: Angle)
    case LeftOf(Ray2d)
    indirect case Union(HitArea, HitArea)
    indirect case Intersection(HitArea, HitArea)
    indirect case Inversion(HitArea)
}

public func ==(lhs: HitArea, rhs: HitArea) -> Bool {
    // TODO: do not compare only cases but values too
    switch (lhs, rhs) {
    case (.None, .None):
        return true
    case (.Line, .Line):
        return true
    case (.Triangle, .Triangle):
        return true
    case (.Circle, .Circle):
        return true
    case (.Arc, .Arc):
        return true
    case (.Sector, .Sector):
        return true
    case (.LeftOf, .LeftOf):
        return true
    case (.Union, .Union):
        return true
    case (.Intersection, .Intersection):
        return true
    case (.Inversion, .Inversion):
        return true
    default:
        return false
    }
}

extension HitArea {
    public func contains(point: Vec2d, margin: Double = 0) -> Bool {
        switch self {
        case None:
            return false
        case .Line(let segment):
            return onLineSegment(point, lineSegment: segment, epsilon: 0.5)
        case .Circle(let circle):
            return inside(point, circle: circle, epsilon: margin)
        case .Arc(let arc):
            return inside(point, arc: arc, epsilon: margin)
        case .Sector(let center, let lower, let upper):
            let a = angle(point-center)
            return isBetween(a, lower: lower, upper: upper)
        case Triangle(let triangle):
            return inside(point, triangle: triangle, epsilon: margin)
        case LeftOf(let ray):
            return leftOf(point, ray: ray, epsilon: margin)
        case .Union(let a, let b):
            return a.contains(point) || b.contains(point)
        case .Intersection(let a, let b):
            return a.contains(point) && b.contains(point)
        case Inversion(let area):
            return !area.contains(point)
        }
    }
}

extension HitArea {
    public func intersects(aabb: AABB2d) -> Bool {
        switch self {
        case None:
            return false
        case .Line(let line):
            return ReformMath.intersects(aabb: aabb, line: line)
        case .Circle(let circle):
            return ReformMath.intersects(aabb: aabb, circle: circle)
        case .Arc(let arc):
            return ReformMath.intersects(aabb: aabb, arc: arc)
        case .Sector(let center, let lower, let upper):
            return isBetween(angle(aabb.min-center), lower: lower, upper: upper)
                || isBetween(angle(aabb.max-center), lower: lower, upper: upper)
                || isBetween(angle(aabb.xMaxYMin-center), lower: lower, upper: upper)
                || isBetween(angle(aabb.xMinYMax-center), lower: lower, upper: upper)
                || ReformMath.intersects(aabb: aabb, ray: Ray2d(from: center, angle: lower))
                || ReformMath.intersects(aabb: aabb, ray: Ray2d(from: center, angle: upper))
        case Triangle(let triangle):
            return ReformMath.intersects(aabb: aabb, triangle: triangle)
        case LeftOf(let ray):
            return leftOf(aabb.min, ray: ray)
                || leftOf(aabb.max, ray: ray)
                || leftOf(aabb.xMaxYMin, ray: ray)
                || leftOf(aabb.xMaxYMin, ray: ray)
        case .Union(let a, let b):
            return a.intersects(aabb) || b.intersects(aabb)
        case .Intersection(let a, let b):
            return a.intersects(aabb) && b.intersects(aabb)
        case Inversion(let area):
            return !area.intersects(aabb)
        }
    }
}