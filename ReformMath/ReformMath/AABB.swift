//
//  AABB.swift
//  ReformMath
//
//  Created by Laszlo Korte on 06.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct AABB : Equatable {
    public let min: Vec2d
    public let max: Vec2d

    public init(min: Vec2d, max: Vec2d) {
        self.min = ReformMath.min(min, max)
        self.max = ReformMath.max(min, max)
    }
}

public func ==(lhs: AABB, rhs: AABB) -> Bool {
    return lhs.min == rhs.min && lhs.max == rhs.max
}

extension AABB {
    public var xMaxYMin : Vec2d {
        return Vec2d(x: max.x, y: min.y)
    }

    public var xMinYMax : Vec2d {
        return Vec2d(x: min.x, y: max.y)
    }
}

extension AABB {
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

    func outCode(point: Vec2d) -> OutCode {
        var outCode : OutCode = []

        if (point.x < min.x) {
            outCode.insert(.Left)
        } else if (point.x > max.x) {
            outCode.insert(.Right)
        }

        if (point.y < min.y) {
            outCode.insert(.Bottom)
        } else if (point.y > max.y) {
            outCode.insert(.Top)
        }

        return outCode
    }

    public func intersectsLine(from from: Vec2d, to: Vec2d) -> Bool {
        let fromOut = outCode(from)
        let toOut = outCode(to)

        if fromOut.union(toOut) == .Inside {
            return true
        } else if fromOut.intersect(toOut) != .Inside {
            return false
        } else {
            if fromOut == .Inside {
                return true
            } else if toOut == .Inside {
                return true
            } else if toOut != fromOut {
                let u = toOut.union(fromOut)
                if !u.contains(.Bottom) && !u.contains(.Top) {
                    return true
                } else if !u.contains(.Left) && !u.contains(.Right) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }

    public func intersectsCircle(center center: Vec2d, radius: Double) -> Bool {

        let size = max - min

        let circleDistance = abs(center - (min+max)/2)

        if (circleDistance.x > (size.x/2 + radius)) { return false }
        if (circleDistance.y > (size.y/2 + radius)) { return false }

        if (circleDistance.x <= (size.x/2)) { return true; }
        if (circleDistance.y <= (size.y/2)) { return true; }

        return (circleDistance - size/2).length2 <= radius*radius;
    }
}

