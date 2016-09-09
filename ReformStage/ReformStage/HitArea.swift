//
//  HitArea.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public enum HitArea : Equatable {
    case none
    case line(LineSegment2d)
    case triangle(Triangle2d)
    case circle(Circle2d)
    case arc(Arc2d)
    case sector(center: Vec2d, range: AngleRange)
    case leftOf(Line2d)
    indirect case union(HitArea, HitArea)
    indirect case intersection(HitArea, HitArea)
    indirect case inversion(HitArea)
}

public func ==(lhs: HitArea, rhs: HitArea) -> Bool {
    // TODO: do not compare only cases but values too
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.line, .line):
        return true
    case (.triangle, .triangle):
        return true
    case (.circle, .circle):
        return true
    case (.arc, .arc):
        return true
    case (.sector, .sector):
        return true
    case (.leftOf, .leftOf):
        return true
    case (.union, .union):
        return true
    case (.intersection, .intersection):
        return true
    case (.inversion, .inversion):
        return true
    default:
        return false
    }
}

extension HitArea {
    public func contains(_ point: Vec2d, margin: Double = 0) -> Bool {
        switch self {
        case .none:
            return false
        case .line(let segment):
            return incident(point, lineSegment: segment, epsilon: 0.5)
        case .circle(let circle):
            return inside(point, circle: circle, epsilon: margin)
        case .arc(let arc):
            return inside(point, arc: arc, epsilon: margin)
        case .sector(let center, let range):
            let a = angle(point-center)
            return inside(a, range: range)
        case .triangle(let triangle):
            return inside(point, triangle: triangle, epsilon: margin)
        case .leftOf(let line):
            return ReformMath.leftOf(point, line: line, epsilon: margin)
        case .union(let a, let b):
            return a.contains(point) || b.contains(point)
        case .intersection(let a, let b):
            return a.contains(point) && b.contains(point)
        case .inversion(let area):
            return !area.contains(point)
        }
    }
}

extension HitArea {
    public func overlaps(_ aabb: AABB2d) -> Bool {
        switch self {
        case .none:
            return false
        case .line(let line):
            return ReformMath.overlaps(aabb: aabb, line: line)
        case .circle(let circle):
            return ReformMath.overlaps(aabb: aabb, circle: circle)
        case .arc(let arc):
            return ReformMath.overlaps(aabb: aabb, arc: arc)
        case .sector(let center, let range):
            return inside(angle(aabb.min-center), range: range)
                || inside(angle(aabb.max-center), range: range)
                || inside(angle(aabb.xMaxYMin-center), range: range)
                || inside(angle(aabb.xMinYMax-center), range: range)
                || ReformMath.overlaps(aabb: aabb, ray: Ray2d(from: center, angle: range.start))
                || ReformMath.overlaps(aabb: aabb, ray: Ray2d(from: center, angle: range.end))
        case .triangle(let triangle):
            return ReformMath.overlaps(aabb: aabb, triangle: triangle)
        case .leftOf(let line):
            return ReformMath.leftOf(aabb.min, line: line)
                || ReformMath.leftOf(aabb.max, line: line)
                || ReformMath.leftOf(aabb.xMaxYMin, line: line)
                || ReformMath.leftOf(aabb.xMaxYMin, line: line)
        case .union(let a, let b):
            return a.overlaps(aabb) || b.overlaps(aabb)
        case .intersection(let a, let b):
            return a.overlaps(aabb) && b.overlaps(aabb)
        case .inversion(let area):
            return !area.overlaps(aabb)
        }
    }
}
