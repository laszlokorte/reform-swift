//
//  Triangle2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 21.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Triangle2d : Equatable {
    public let a: Vec2d
    public let b: Vec2d
    public let c: Vec2d

    public init(a: Vec2d, b: Vec2d, c: Vec2d) {
        self.a = a
        self.b = b
        self.c = c
    }
}

public func ==(lhs: Triangle2d, rhs: Triangle2d) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
}

extension Triangle2d {
    public var area : Double {
        // Heron's formula
        let s = circumference / 2
        let la = distance(point: a,point: b)
        let lb = distance(point: b,point: c)
        let lc = distance(point: c,point: a)
        return sqrt(s * (s-la) * (s-lb) * (s-lc))
    }

    public var circumference : Double {
        return distance(point: a, point: b) + distance(point: b, point: c) + distance(point: c, point: a)
    }
}