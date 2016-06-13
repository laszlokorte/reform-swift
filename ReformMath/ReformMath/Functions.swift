//
//  Functions.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func rotate(_ vector: Vec2d, angle: Angle) -> Vec2d {
    let cs = cos(angle.radians)
    let sn = sin(angle.radians)
    
    return Vec2d(x: vector.x * cs - vector.y * sn, y: vector.x * sn + vector.y * cs)
}

public func angle(_ vector: Vec2d) -> Angle {
    return normalize360(Angle(radians: atan2(vector.y,vector.x)))
}

public func angleBetween(vector a: Vec2d, vector b: Vec2d) -> Angle {
    return normalize360(angle(a) - angle(b))
}

public func clamp<T:Comparable>(_ value: T, between: T, and: T) -> T {
    return max(between, min(value, and))
}

public func lerp(_ t:Double, a: Vec2d, b: Vec2d) -> Vec2d {
    return Vec2d(x: lerp(t, a: a.x, b: b.x), y: lerp(t, a: a.y, b: b.y))
}

public func lerp(_ t:Double, a: Angle, b: Angle) -> Angle {
    return Angle(radians: lerp(t, a: a.radians, b: b.radians))
}

public func lerp(_ t:Double, a: Double, b: Double) -> Double {
    return a*(1-t) + t*b
}

public func project(_ vector: Vec2d, onto: Vec2d) -> Vec2d {
    guard onto.x != 0 || onto.y != 0 else { return vector }
    
    return dot(vector, onto) * onto / onto.length²
}

public func dot(_ a: Vec2d, _ b: Vec2d) -> Double {
    return a.x * b.x + a.y * b.y
}

public func orthogonal(_ vector: Vec2d) -> Vec2d {
    return Vec2d(x:-vector.y, y: vector.x)
}

public func signum(_ num: Double) -> Double {
    if num > 0  { return 1 }
    else if num < 0 { return -1 }
    else { return 0 }
}

public func proportioned(_ vector: Vec2d, proportion: Double, large: Bool) -> Vec2d {
    let op : (Double, Double)->Double = large ? max : min
    let base = op(abs(vector.x), abs(vector.y / proportion))

    let signs = Vec2d(
        x: vector.x < 0 ? -1 : 1,
        y: vector.y < 0 ? -1 : 1
    )

    return signs * Vec2d(x: base, y: base * proportion)

}

public func signum(_ vector: Vec2d) -> Vec2d {
    return Vec2d(x: signum(vector.x), y: signum(vector.y))
}

public func abs(_ vector: Vec2d) -> Vec2d {
    return Vec2d(x: abs(vector.x), y: abs(vector.y))
}

public func min(_ vector: Vec2d) -> Double {
    return min(vector.x, vector.y)
}

public func max(_ vector: Vec2d) -> Double {
    return max(vector.x, vector.y)
}

public func stepped(_ angle: Angle, size: Angle) -> Angle {
    return Angle(radians: stepped(angle.radians, size: size.radians))
}


public func stepped(_ value: Double, size: Double) -> Double {
    return round(value / size) * size
}

public func normalize(_ vector: Vec2d) -> Vec2d? {
    let length = vector.length
    guard length != 0 else {
        return nil
    }
    
    return vector / length
}

public func normalize360(_ angle: Angle) -> Angle{
    let deg = angle.degree
    let norm = Double(Int(deg) % 360) + (deg-trunc(deg))
    if(norm>0.0) {
        return Angle(degree: norm)
    }
    else {
        return Angle(degree: norm + 360)
    }
}

public func min(_ a: Vec2d, _ b: Vec2d) -> Vec2d {
    return Vec2d(x: min(a.x,b.x), y: min(a.y,b.y))
}

public func max(_ a: Vec2d, _ b: Vec2d) -> Vec2d {
    return Vec2d(x: max(a.x,b.x), y: max(a.y,b.y))
}


public func union(aabb a: AABB2d, aabb b: AABB2d) -> AABB2d {
    return AABB2d(min: min(a.min, b.min), max: max(a.max, b.max))
}



public func determinant(matrix m: Mat3x2) -> Double {
    return m.col1.x * m.col2.y - m.col2.x * m.col1.y
}

public func inverse(matrix m: Mat3x2) -> Mat3x2? {
    let det = determinant(matrix: m)

    guard det != 0 else {
        return nil
    }

    let invDet = 1/det

    let col1 = Vec2d(
        x: invDet * (m.col2.y /*(* 1)*/ /*- 0 * m.col3.y*/),
        y: invDet * (/*0 * m.col3.y*/ -m.col1.y /*(* 1)*/)
    )

    let col2 = Vec2d(
        x: invDet * (/*0 * m.col3.x*/ -m.col2.x /*(* 1)*/),
        y: invDet * (m.col1.x /*(* 1)*/ /*- 0 * m.col3.x*/)
    )

    let col3 = Vec2d(
        x: invDet * (m.col2.x * m.col3.y - m.col2.y * m.col3.x),
        y: invDet * (m.col1.y * m.col3.x - m.col1.x * m.col3.y)
    )
    return Mat3x2(col1: col1, col2: col2, col3: col3)
}




public func rotate(_ aabb: AABB2d, angle: Angle) -> AABB2d {
    let sizeHalf = aabb.size/2

    return AABB2d(center: aabb.center, size: 2*rotate(sizeHalf, angle: angle))
}
