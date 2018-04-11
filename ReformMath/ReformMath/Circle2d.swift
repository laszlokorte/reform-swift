//
//  Circle2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 21.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Circle2d : Equatable {
    public let center: Vec2d
    public let radius: Double

    public init(center: Vec2d, radius: Double) {
        self.center = center
        self.radius = radius
    }
}

public func ==(lhs: Circle2d, rhs: Circle2d) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

extension Circle2d {
    public var circumference : Double {
        return 2*Double.TAU*radius
    }
}
