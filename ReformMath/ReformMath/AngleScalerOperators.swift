//
//  AngleScalerOperators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 12.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func *(lhs: Angle, rhs: Double) -> Angle {
    return Angle(radians: lhs.radians * rhs)
}

public func *(lhs: Double, rhs: Angle) -> Angle {
    return Angle(radians: lhs * rhs.radians)
}

public func /(lhs: Angle, rhs: Double) -> Angle {
    return Angle(radians: lhs.radians / rhs)
}