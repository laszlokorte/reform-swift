//
//  Intersection.swift
//  ReformMath
//
//  Created by Laszlo Korte on 22.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

func intersection(range rangeA: (from: Angle, to: Angle), range rangeB: (from: Angle, to:Angle)) -> (Angle, Angle)? {
    let from = max(rangeA.from, rangeB.from)
    let to = min(rangeA.to, rangeB.to)

    if from <= to {
        return (from, to)
    } else {
        return nil
    }
}

public func intersection(line lineA: LineSegment2d, line lineB: LineSegment2d) -> Vec2d? {
    // ref http://paulbourke.net/geometry/pointlineplane/

    let d = (lineB.to.y - lineB.from.y) * (lineA.to.x - lineA.from.x) - (lineB.to.x - lineB.from.x) * (lineA.to.y - lineA.from.y)

    let na = (lineB.to.x - lineB.from.x) * (lineA.from.y - lineB.from.y) - (lineB.to.y - lineB.from.y) * (lineA.from.x - lineB.from.x)
    let nb = (lineA.to.x - lineA.from.x) * (lineA.from.y - lineB.from.y) - (lineA.to.y - lineA.from.y) * (lineA.from.x - lineB.from.x)

    // lines are coincident
    if na == 0 && nb == 0 {
        return nil
    }

    // lines are parallel
    if d == 0 {
        return nil
    }

    let ua = na / d
    let ub = nb / d


    // "intersection is beyond end of segment"
    guard (ua >= EPSILON && ua <= 1 - EPSILON && ub >= EPSILON && ub < 1 - EPSILON) else {
        return nil
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
        return []
    }

    let a = (circleA.radius * circleA.radius - circleB.radius * circleB.radius + d * d) / (2 * d)
    let c = circleA.center + delta * a / d

    let hh = circleA.radius * circleA.radius - a * a

    guard (hh >= 0) else {
        return []
    }

    let h = sqrt(hh)
    let r = orthogonal(delta) * h / d

    var result = [c+r]
    if abs(d - (circleA.radius + circleB.radius)) > EPSILON {
        result.append(c-r)
    }

    return result
}

public func intersections(line line: LineSegment2d, circle: Circle2d) -> [Vec2d] {

    let a = (line.to.x - line.from.x) * (line.to.x - line.from.x) + (line.to.y - line.from.y) * (line.to.y - line.from.y)
    let b = 2 * ((line.to.x - line.from.x) * (line.from.x - circle.center.x) + (line.to.y - line.from.y) * (line.from.y - circle.center.y))
    let c = circle.center.x * circle.center.x + circle.center.y * circle.center.y + line.from.x * line.from.x + line.from.y * line.from.y - 2 *
        (circle.center.x * line.from.x + circle.center.y * line.from.y) - circle.radius * circle.radius

    var det = b * b - 4 * a * c
    if (abs(det) < 1e-8)
    {
        det = 0
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


