//
//  Relations.swift
//  ReformMath
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

let EPSILON = 0.000001

public func intersection(line lineA: LineSegment2d, line lineB: LineSegment2d) -> Vec2d? {
    // ref http://paulbourke.net/geometry/pointlineplane/
    
    let d = (lineB.to.y - lineB.from.y) * (lineA.to.x - lineA.from.x) - (lineB.to.x - lineB.from.x) * (lineA.to.y - lineA.from.y);
    
    let na = (lineB.to.x - lineB.from.x) * (lineA.from.y - lineB.from.y) - (lineB.to.y - lineB.from.y) * (lineA.from.x - lineB.from.x);
    let nb = (lineA.to.x - lineA.from.x) * (lineA.from.y - lineB.from.y) - (lineA.to.y - lineA.from.y) * (lineA.from.x - lineB.from.x);
    
    // lines are coincident
    guard (na != 0 || nb != 0 || d != 0) else {
        return nil;
    }
    
    // lines are parallel
    guard (d != 0) else {
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

public func intersections(arc arcA: Arc2d, arc arcB: Arc2d) -> [Vec2d] {
    
    let delta = arcB.center - arcA.center
    let d = delta.length
    
    guard (d != 0) else {
        return []
    }
    guard (d < arcA.radius + arcB.radius) else {
        return []
    }
    guard (d > abs(arcA.radius - arcB.radius)) else {
        return [];
    }
    
    let a = (arcA.radius * arcA.radius - arcB.radius * arcB.radius + d * d) / (2 * d)
    let c = arcA.center + delta * a / d
    
    let hh = arcA.radius * arcA.radius - a * a;
    
    guard (hh >= 0) else {
        return [];
    }
    
    let h = sqrt(hh);
    let r = -delta * h / d
    
    var result = [c+r]
    if abs(d - (arcA.radius + arcB.radius)) > EPSILON {
        result.append(c-r)
    }
    
    return result
}

public func intersections(line line: LineSegment2d, arc: Arc2d) -> [Vec2d] {
    
    let a = (line.to.x - line.from.x) * (line.to.x - line.from.x) + (line.to.y - line.from.y) * (line.to.y - line.from.y);
    let b = 2 * ((line.to.x - line.from.x) * (line.from.x - arc.center.x) + (line.to.y - line.from.y) * (line.from.y - arc.center.y));
    let c = arc.center.x * arc.center.x + arc.center.y * arc.center.y + line.from.x * line.from.x + line.from.y * line.from.y - 2 *
        (arc.center.x * line.from.x + arc.center.y * line.from.y) - arc.radius * arc.radius;
    
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