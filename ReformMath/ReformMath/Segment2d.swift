//
//  Segment2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 23.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public struct Segment2d : Equatable {
    let arc : Arc2d

    public init(center: Vec2d, radius:Double, range: AngleRange) {
        self.arc = Arc2d(center: center, radius: radius, range: range)
    }
}

public func ==(lhs: Segment2d, rhs: Segment2d) -> Bool {
    return lhs.arc == rhs.arc
}