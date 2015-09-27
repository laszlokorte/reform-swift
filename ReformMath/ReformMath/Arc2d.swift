//
//  Arc2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 21.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Arc2d : Equatable {
    public let center : Vec2d
    public let radius: Double
    public let range: AngleRange

    public init(center: Vec2d, radius:Double, range: AngleRange) {
        self.center = center
        self.radius = radius
        self.range = range
    }
}

public func ==(lhs: Arc2d, rhs: Arc2d) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius && lhs.range == rhs.range
}

extension Arc2d {
    public var length : Double {
        return 2 * M_PI * radius * range.delta.percent/100
    }
}

extension Arc2d {
    public var circle : Circle2d {
        return Circle2d(center: center, radius: radius)
    }

    public var quadrants : [Arc2d] {
        return [
            AngleRange(start: Angle(percent: 0), end: Angle(percent: 25)),
            AngleRange(start: Angle(percent: 25), end: Angle(percent: 50)),
            AngleRange(start: Angle(percent: 50), end: Angle(percent: 75)),
            AngleRange(start: Angle(percent: 75), end: Angle(percent: 100)),
        ].lazy.flatMap { (r:AngleRange) in
            intersection(range: range, range: self.range)
        }.flatMap { (r:AngleRange) in
            Arc2d(center: center, radius: radius, range: r)
        }
    }
}
