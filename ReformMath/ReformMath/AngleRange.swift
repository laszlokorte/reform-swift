//
//  AngleRange.swift
//  ReformMath
//
//  Created by Laszlo Korte on 27.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct AngleRange : Equatable {
    public let start: Angle
    public let end: Angle

    public init(start: Angle, end: Angle) {
        self.start = normalize360(start)
        self.end = normalize360(end)
    }
}

public func ==(lhs:AngleRange, rhs:AngleRange) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

extension AngleRange {
    var delta : Angle {
        return normalize360(end-start)
    }
}