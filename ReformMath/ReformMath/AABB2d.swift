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
    public var xMaxYMin : Vec2d {
        return Vec2d(x: max.x, y: min.y)
    }

    public var xMinYMax : Vec2d {
        return Vec2d(x: min.x, y: max.y)
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

    public func intersectsLine(var from from: Vec2d, var to: Vec2d) -> Bool {
        var fromOut = outCode(from)
        var toOut = outCode(to)
        while true {

            if fromOut.union(toOut) == .Inside {
                return true
            } else if fromOut.intersect(toOut) != .Inside {
                return false
            } else {
                // failed both tests, so calculate the line segment to clip
                // from an outside point to an intersection with clip edge
                let x : Double
                let y : Double

                // At least one endpoint is outside the clip rectangle; pick it.
                let outcodeOut = fromOut != .Inside ? fromOut : toOut

                // Now find the intersection point;
                // use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
                if (outcodeOut.contains(.Top)) {           // point is above the clip rectangle
                    x = from.x + (to.x - from.x) * (max.y - from.y) / (to.y - from.y)
                    y = max.y
                } else if (outcodeOut.contains(.Bottom)) { // point is below the clip rectangle
                    x = from.x + (to.x - from.x) * (min.y - from.y) / (to.y - from.y)
                    y = min.y
                } else if (outcodeOut.contains(.Right)) {  // point is to the right of clip rectangle
                    y = from.y + (to.y - from.y) * (max.x - from.x) / (to.x - from.x)
                    x = max.x
                } else if (outcodeOut.contains(.Left)) {   // point is to the left of clip rectangle
                    y = from.y + (to.y - from.y) * (min.x - from.x) / (to.x - from.x)
                    x = min.x
                } else {
                    return false
                }
                
                // Now we move outside point to intersection point to clip
                // and get ready for next pass.
                if (outcodeOut == fromOut) {
                    from = Vec2d(x: x, y: y)
                    fromOut = outCode(from)
                } else {
                    to = Vec2d(x: x, y: y)
                    toOut = outCode(to)
                }
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

