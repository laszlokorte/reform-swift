//
//  GridSnapPoint.swift
//  ReformStage
//
//  Created by Laszlo Korte on 01.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore

public struct GridSnapPoint : SnapPoint, Equatable {
    public let position : Vec2d
    let point : GridPoint

    public init(position: Vec2d, point: GridPoint) {
        self.position = position
        self.point = point
    }

    public var label : String {
        return String(format: "%.1%% Horizontally, %.1f%% Vertically", point.percent.x * 100, point.percent.y * 100)
    }

    public var runtimePoint : LabeledPoint {
        return point
    }

    public func belongsTo(_ formId: FormIdentifier) -> Bool {
        return false
    }
}

public func ==(lhs: GridSnapPoint, rhs: GridSnapPoint) -> Bool {
    return lhs.position == rhs.position && lhs.point == rhs.point
}
