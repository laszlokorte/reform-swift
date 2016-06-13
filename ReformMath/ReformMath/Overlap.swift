//
//  Overlap.swift
//  ReformMath
//
//  Created by Laszlo Korte on 23.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func overlaps(aabb: AABB2d, line: LineSegment2d) -> Bool {
    // https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
    var from = line.from
    var to = line.to
    var fromOut = aabb.outCode(from)
    var toOut = aabb.outCode(to)
    while true {

        if fromOut.union(toOut) == .Inside {
            return true
        } else if fromOut.intersection(toOut) != .Inside {
            return false
        } else {
            let x : Double
            let y : Double

            let outcodeOut = fromOut != .Inside ? fromOut : toOut

            if (outcodeOut.contains(.Top)) {
                x = from.x + (to.x - from.x) * (aabb.max.y - from.y) / (to.y - from.y)
                y = aabb.max.y
            } else if (outcodeOut.contains(.Bottom)) {
                x = from.x + (to.x - from.x) * (aabb.min.y - from.y) / (to.y - from.y)
                y = aabb.min.y
            } else if (outcodeOut.contains(.Right)) {
                y = from.y + (to.y - from.y) * (aabb.max.x - from.x) / (to.x - from.x)
                x = aabb.max.x
            } else if (outcodeOut.contains(.Left)) {
                y = from.y + (to.y - from.y) * (aabb.min.x - from.x) / (to.x - from.x)
                x = aabb.min.x
            } else {
                return false
            }

            if (outcodeOut == fromOut) {
                from = Vec2d(x: x, y: y)
                fromOut = aabb.outCode(from)
            } else {
                to = Vec2d(x: x, y: y)
                toOut = aabb.outCode(to)
            }
        }
    }

}

public func overlaps(aabb: AABB2d, ray: Ray2d) -> Bool {
    let inv = 1/ray.direction

    let tx1 = (aabb.min.x - ray.from.x)*inv.x
    let tx2 = (aabb.max.x - ray.from.x)*inv.x

    let tmin = min(tx1, tx2)
    let tmax = max(tx1, tx2)

    let ty1 = (aabb.min.y - ray.from.y)*inv.y
    let ty2 = (aabb.max.y - ray.from.y)*inv.y

    let tmin2 = max(tmin, min(ty1, ty2))
    let tmax2 = min(tmax, max(ty1, ty2))

    return  tmax2 >= tmin2 && tx1 >= 0 && ty1 >= 0
}

public func overlaps(aabb: AABB2d, line: Line2d) -> Bool {
    let inv = 1/line.direction

    let tx1 = (aabb.min.x - line.from.x)*inv.x
    let tx2 = (aabb.max.x - line.from.x)*inv.x

    let tmin = min(tx1, tx2)
    let tmax = max(tx1, tx2)

    let ty1 = (aabb.min.y - line.from.y)*inv.y
    let ty2 = (aabb.max.y - line.from.y)*inv.y

    let tmin2 = max(tmin, min(ty1, ty2))
    let tmax2 = min(tmax, max(ty1, ty2))

    return  tmax2 >= tmin2
}

public func overlaps(aabb: AABB2d, circle: Circle2d) -> Bool {
    let size = aabb.max - aabb.min

    let circleDistance = abs(circle.center - (aabb.min+aabb.max)/2)

    if (circleDistance.x > (size.x/2 + circle.radius)) { return false }
    if (circleDistance.y > (size.y/2 + circle.radius)) { return false }

    if (circleDistance.x <= (size.x/2)) { return true }
    if (circleDistance.y <= (size.y/2)) { return true }

    return (circleDistance - size/2).length² <= circle.radius*circle.radius

}

public func overlaps(aabb: AABB2d, arc: Arc2d) -> Bool {
    let circleDistance = abs(arc.center - aabb.center)

    if (circleDistance.x > (aabb.size.x/2 + arc.radius)) { return false }
    if (circleDistance.y > (aabb.size.y/2 + arc.radius)) { return false }

    if (circleDistance.x <= (aabb.size.x/2)) { return true }
    if (circleDistance.y <= (aabb.size.y/2)) { return true }

    return !intersections(line: aabb.top, arc: arc).isEmpty
        || !intersections(line: aabb.left, arc: arc).isEmpty
        || !intersections(line: aabb.bottom, arc: arc).isEmpty
        || !intersections(line: aabb.right, arc: arc).isEmpty

}

public func overlaps(aabb: AABB2d, triangle: Triangle2d) -> Bool {
    return overlaps(aabb: aabb, line: LineSegment2d(from: triangle.a, to: triangle.b)) || overlaps(aabb: aabb, line: LineSegment2d(from: triangle.b, to: triangle.c)) || overlaps(aabb: aabb, line: LineSegment2d(from: triangle.c, to: triangle.a))
}
