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
    public let start: Angle
    public let end: Angle

    public init(center: Vec2d, radius:Double, start: Angle, end: Angle) {
        self.center = center
        self.radius = radius
        self.start = start
        self.end = end
    }
}

public func ==(lhs: Arc2d, rhs: Arc2d) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius && lhs.start == rhs.start && lhs.end == rhs.end
}

extension Arc2d {
    public var length : Double {
        return 2 * M_PI * radius * normalize360(end-start).percent/100
    }
}
