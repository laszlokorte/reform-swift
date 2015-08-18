//
//  Functions.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func rotate(vector: Vec2d, angle: Angle) -> Vec2d {
    let cs = cos(angle.radians)
    let sn = sin(angle.radians)
    
    return Vec2d(x: vector.x * cs - vector.y * sn, y: vector.x * sn + vector.y * cs)
}

public func angle(vector: Vec2d) -> Angle {
    return Angle(radians: atan2(-vector.y,-vector.x))
}

public func clamp<T:Comparable>(value: T, between: T, and: T) -> T {
    return max(between, min(value, and))
}

public func lerp(t:Double, a: Vec2d, b: Vec2d) -> Vec2d {
    return Vec2d(x: lerp(t, a: a.x, b: b.x), y: lerp(t, a: a.y, b: b.y))
}

public func lerp(t:Double, a: Double, b: Double) -> Double {
    return a*(1-t) + t*b
}

public func project(vector: Vec2d, onto: Vec2d) -> Vec2d {
    guard onto.x != 0 || onto.y != 0 else { return vector }
    
    return dot(vector, onto) * onto / onto.length2;
}

public func dot(a: Vec2d, _ b: Vec2d) -> Double {
    return a.x * b.x + a.y * b.y
}

public func orthogonal(vector: Vec2d) -> Vec2d {
    return Vec2d(x:-vector.y, y: vector.x)
}

func signum(num: Double) -> Double {
    if num > 0  { return 1 }
    else if num < 0 { return -1 }
    else { return 0 }
}

public func proportioned(vector: Vec2d, proportion: Double) -> Vec2d {

    let minimum = min(abs(vector.x), abs(vector.y / proportion));
    
    return Vec2d(x: minimum * signum(vector.x), y: minimum * signum(vector.x) * proportion)

}

public func signum(vector: Vec2d) -> Vec2d {
    return Vec2d(x: signum(vector.x), y: signum(vector.y))
}

public func abs(vector: Vec2d) -> Vec2d {
    return Vec2d(x: abs(vector.x), y: abs(vector.y))
}

public func min(vector: Vec2d) -> Double {
    return min(vector.x, vector.y)
}

public func max(vector: Vec2d) -> Double {
    return max(vector.x, vector.y)
}

public func stepped(angle: Angle, size: Angle) -> Angle {
    return Angle(radians: stepped(angle.radians, size: size.radians))
}


public func stepped(value: Double, size: Double) -> Double {
    return round(value / size) * size
}