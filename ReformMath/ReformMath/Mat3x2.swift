//
//  Mat3x2.swift
//  ReformMath
//
//  Created by Laszlo Korte on 03.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct Mat3x2 : Equatable {
    public static let Identity = Mat3x2()
    public static let Zero = Mat3x2(col1: Vec2d.Zero, col2: Vec2d.Zero, col3: Vec2d.Zero)

    public let col1 : Vec2d
    public let col2 : Vec2d
    public let col3 : Vec2d

    public init() {
        col1 = Vec2d.XAxis
        col2 = Vec2d.YAxis
        col3 = Vec2d.Zero
    }

    public init(scale factor: Double) {
        col1 = factor * Vec2d.XAxis
        col2 = factor * Vec2d.YAxis
        col3 = Vec2d.Zero
    }

    public init(translate delta: Vec2d) {
        col1 = Vec2d.XAxis
        col2 = Vec2d.YAxis
        col3 = delta
    }

    public init(rotate angle: Angle) {
        col1 = Vec2d(x: angle.sin, y: angle.cos)
        col2 = Vec2d(x: -angle.sin, y: angle.cos)
        col3 = Vec2d.Zero
    }

    public init(col1: Vec2d, col2: Vec2d, col3: Vec2d) {
        self.col1 = col1
        self.col2 = col2
        self.col3 = col3
    }
}

public func ==(lhs: Mat3x2, rhs: Mat3x2) -> Bool {
    return lhs.col1 == rhs.col1 && lhs.col2 == rhs.col2 && lhs.col3 == rhs.col3
}

extension Mat3x2 {
    public init(rotate angle: Angle, fix: Vec2d) {
        self = Mat3x2(translate: fix) * Mat3x2(rotate: angle) * Mat3x2(translate: -fix)
    }

    public init(scale factor: Double, fix: Vec2d) {
        self = Mat3x2(translate: fix) * Mat3x2(scale: factor) * Mat3x2(translate: -fix)
    }
}