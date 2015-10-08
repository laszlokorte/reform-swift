//
//  AABB.swift
//  ReformMath
//
//  Created by Laszlo Korte on 06.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct AABB2d : Equatable {
    public let min: Vec2d
    public let max: Vec2d

    public init(min: Vec2d, max: Vec2d) {
        self.min = ReformMath.min(min, max)
        self.max = ReformMath.max(min, max)
    }

}

public func ==(lhs: AABB2d, rhs: AABB2d) -> Bool {
    return lhs.min == rhs.min && lhs.max == rhs.max
}

extension AABB2d {
    public init(center: Vec2d, size: Vec2d) {
        self.init(min: center-size, max: center+size)
    }
}

extension AABB2d {
    public var xMaxYMin : Vec2d {
        return Vec2d(x: max.x, y: min.y)
    }

    public var xMinYMax : Vec2d {
        return Vec2d(x: min.x, y: max.y)
    }

    public var center : Vec2d {
        return (min + max) / 2
    }

    public var size : Vec2d {
        return max - min
    }
}

extension AABB2d {
    public var top : LineSegment2d {
        return LineSegment2d(from: xMinYMax, to: max)
    }

    public var bottom : LineSegment2d {
        return LineSegment2d(from: min, to: xMaxYMin)
    }

    public var left : LineSegment2d {
        return LineSegment2d(from: min, to: xMinYMax)
    }

    public var right : LineSegment2d {
        return LineSegment2d(from: xMaxYMin, to: max)
    }
}

extension AABB2d {
    struct OutCode : OptionSetType, CustomDebugStringConvertible {
        let rawValue: UInt8

        static let Inside = OutCode(rawValue: 0b0000)
        static let Left = OutCode(rawValue:   0b0001)
        static let Right = OutCode(rawValue:  0b0010)
        static let Bottom = OutCode(rawValue: 0b0100)
        static let Top = OutCode(rawValue:    0b1000)

        private static let strings : [(OutCode,String)] = [
            (.Inside, "Inside"),
            (.Left, "Left"),
            (.Right, "Right"),
            (.Bottom,  "Bottom"),
            (.Top, "Top")
        ]

        var debugDescription : String {
            var result : [String] = []

            for (c, s) in OutCode.strings {
                if self.contains(c) {
                    result.append(s)
                }
            }

            return result.joinWithSeparator(",")
        }
    }

    func outCode(point: Vec2d, epsilon:Double = 0) -> OutCode {
        var outCode : OutCode = []

        if (point.x < min.x - epsilon) {
            outCode.insert(.Left)
        } else if (point.x > max.x + epsilon) {
            outCode.insert(.Right)
        }

        if (point.y < min.y - epsilon) {
            outCode.insert(.Bottom)
        } else if (point.y > max.y + epsilon) {
            outCode.insert(.Top)
        }

        return outCode
    }
}

