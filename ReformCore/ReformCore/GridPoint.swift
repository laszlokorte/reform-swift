//
//  GridPoint.swift
//  ReformCore
//
//  Created by Laszlo Korte on 01.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct GridPoint : RuntimePoint, Labeled, Equatable {
    public let percent : Vec2d

    public init(percent: Vec2d) {
        self.percent = percent
    }

    public func getPositionFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        guard let canvas = runtime.get(FormIdentifier(0)) as? Paper else {
            return nil
        }

        guard let
            width = canvas.width.getLengthFor(runtime),
            height = canvas.height.getLengthFor(runtime) else {
                return nil
        }

        return Vec2d(x: width, y: height) * percent
    }

    public func getDescription(_ stringifier: Stringifier) -> String {
        return String(format: "%.1f%% Horizontally, %.1f%% Vertically", percent.x * 100, percent.y * 100)
    }
}

public func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {
    return lhs.percent == rhs.percent
}
