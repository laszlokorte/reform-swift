//
//  AngleAngleOperators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 12.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public func +(lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians + rhs.radians)
}

public func -(lhs: Angle, rhs: Angle) -> Angle {
    return Angle(radians: lhs.radians - rhs.radians)
}

public prefix func -(op: Angle) -> Angle {
    return Angle(radians: -op.radians)
}

public func /(lhs: Angle, rhs: Angle) -> Double {
    return lhs.radians / rhs.radians
}
