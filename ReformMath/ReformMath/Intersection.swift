//
//  Intersection.swift
//  ReformMath
//
//  Created by Laszlo Korte on 22.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public func intersection(line lineA: LineSegment2d, line lineB: LineSegment2d) -> Vec2d? {
    // ref http://paulbourke.net/geometry/pointlineplane/

    let d = (lineB.to.y - lineB.from.y) * (lineA.to.x - lineA.from.x) - (lineB.to.x - lineB.from.x) * (lineA.to.y - lineA.from.y);

    let na = (lineB.to.x - lineB.from.x) * (lineA.from.y - lineB.from.y) - (lineB.to.y - lineB.from.y) * (lineA.from.x - lineB.from.x);
    let nb = (lineA.to.x - lineA.from.x) * (lineA.from.y - lineB.from.y) - (lineA.to.y - lineA.from.y) * (lineA.from.x - lineB.from.x);

    // lines are coincident
    if na == 0 && nb == 0 {
        return nil;
    }

    // lines are parallel
    if d == 0 {
        return nil;
    }

    let ua = na / d;
    let ub = nb / d;


    // "intersection is beyond end of segment"
    guard (ua >= EPSILON && ua <= 1 - EPSILON && ub >= EPSILON && ub < 1 - EPSILON) else {
        return nil;
    }

    return lerp(ua, a: lineA.from, b: lineA.to)
}

public func intersections(circle circleA: Circle2d, circle circleB: Circle2d) -> [Vec2d] {

    let delta = circleB.center - circleA.center
    let d = delta.length

    guard (d != 0) else {
        return []
    }
    guard (d < circleA.radius + circleB.radius) else {
        return []
    }
    guard (d > abs(circleA.radius - circleB.radius)) else {
        return [];
    }

    let a = (circleA.radius * circleA.radius - circleB.radius * circleB.radius + d * d) / (2 * d)
    let c = circleA.center + delta * a / d

    let hh = circleA.radius * circleA.radius - a * a;

    guard (hh >= 0) else {
        return [];
    }

    let h = sqrt(hh);
    let r = orthogonal(delta) * h / d

    var result = [c+r]
    if abs(d - (circleA.radius + circleB.radius)) > EPSILON {
        result.append(c-r)
    }

    return result
}

public func intersections(line line: LineSegment2d, circle: Circle2d) -> [Vec2d] {

    let a = (line.to.x - line.from.x) * (line.to.x - line.from.x) + (line.to.y - line.from.y) * (line.to.y - line.from.y);
    let b = 2 * ((line.to.x - line.from.x) * (line.from.x - circle.center.x) + (line.to.y - line.from.y) * (line.from.y - circle.center.y));
    let c = circle.center.x * circle.center.x + circle.center.y * circle.center.y + line.from.x * line.from.x + line.from.y * line.from.y - 2 *
        (circle.center.x * line.from.x + circle.center.y * line.from.y) - circle.radius * circle.radius;

    var det = b * b - 4 * a * c;
    if (abs(det) < 1e-8)
    {
        det = 0;
    }
    guard (det >= 0) else
    {
        return []
    }

    let u1 = (-b + sqrt(det)) / (2 * a)
    let u2 = (-b - sqrt(det)) / (2 * a)
    var result = [Vec2d]()

    if (u1 >= 0.001 && u1 <= 0.999)
    {
        result.append(lerp(u1, a: line.from, b: line.to))
    }
    if (u2 >= 0.001 && u2 <= 0.999)
    {
        result.append(lerp(u2, a: line.from, b: line.to))
    }
    
    return result
}



public func intersections(arc arcA: Arc2d, arc arcB: Arc2d) -> [Vec2d] {
    let circleIntersections = intersections(circle: arcA.circle, circle: arcB.circle)

    return circleIntersections.filter {
        point in
        return
            isBetween(angle(point - arcA.center), lower: arcA.start, upper: arcA.end) &&
            isBetween(angle(point - arcB.center), lower: arcB.start, upper: arcB.end)
    }

}

public func intersections(line line: LineSegment2d, arc: Arc2d) -> [Vec2d] {
    let circleIntersections = intersections(line: line, circle: arc.circle)

    return circleIntersections.filter {
        point in
        return isBetween(angle(point - arc.center), lower: arc.start, upper: arc.end)
    }
}

public func intersects(aabb aabb: AABB2d, line: LineSegment2d) -> Bool {
    // https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
    var from = line.from
    var to = line.to
    var fromOut = aabb.outCode(from)
    var toOut = aabb.outCode(to)
    while true {

        if fromOut.union(toOut) == .Inside {
            return true
        } else if fromOut.intersect(toOut) != .Inside {
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

public func intersects(aabb aabb: AABB2d, circle: Circle2d) -> Bool {
    let size = aabb.max - aabb.min

    let circleDistance = abs(circle.center - (aabb.min+aabb.max)/2)

    if (circleDistance.x > (size.x/2 + circle.radius)) { return false }
    if (circleDistance.y > (size.y/2 + circle.radius)) { return false }

    if (circleDistance.x <= (size.x/2)) { return true; }
    if (circleDistance.y <= (size.y/2)) { return true; }

    return (circleDistance - size/2).length2 <= circle.radius*circle.radius;
    
}

public func intersects(aabb aabb: AABB2d, arc: Arc2d) -> Bool {
    let size = aabb.max - aabb.min

    let circleDistance = abs(arc.center - (aabb.min+aabb.max)/2)

    if (circleDistance.x > (size.x/2 + arc.radius)) { return false }
    if (circleDistance.y > (size.y/2 + arc.radius)) { return false }

    if (circleDistance.x <= (size.x/2)) { return true; }
    if (circleDistance.y <= (size.y/2)) { return true; }

    return (circleDistance - size/2).length2 <= arc.radius*arc.radius;
    
}

public func intersects(aabb aabb: AABB2d, triangle: Triangle2d) -> Bool {
    return intersects(aabb: aabb, line: LineSegment2d(from: triangle.a, to: triangle.b)) || intersects(aabb: aabb, line: LineSegment2d(from: triangle.b, to: triangle.c)) || intersects(aabb: aabb, line: LineSegment2d(from: triangle.c, to: triangle.a))
}

