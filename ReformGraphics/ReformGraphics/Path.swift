//
//  Path.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct Path {
    var winding : WindingRule = .nonZero
    var segments : [Segment] = [.moveTo(Vec2d())]
    
    public init(segments: Segment...) {
        self.segments += segments
    }
    
    public mutating func reset() {
        segments.removeAll()
        segments.append(.moveTo(Vec2d()))
    }
    
    public mutating func append(_ segment: Segment) {
        segments.append(segment)
    }

    public enum Segment {
        case moveTo(Vec2d)
        case lineTo(Vec2d)
        case quadraticTo(Vec2d, control: Vec2d)
        case qubicTo(Vec2d, control: Vec2d, control: Vec2d)
        case arcTo(tangent: Vec2d, tangent: Vec2d, radius: Double)
        case close
    }
    
    enum WindingRule {
        case evenOdd
        case nonZero
    }
}

extension Path {
    public init(center: Vec2d, radius: Double, lower: Angle, upper: Angle) {
        let arm = Vec2d(radius: radius, angle: lower)
        let end = Vec2d(radius: radius, angle: upper)
        let outer = Vec2d(radius: radius*sqrt(2), angle: lower + Angle(degree: -45))
        let count = abs(Int(normalize360(upper-lower).degree / 90))
        let rest = Angle(degree: normalize360(upper-lower).degree.truncatingRemainder(dividingBy: 90))


        self.append(.moveTo(center+arm))
        for i in 0..<count {
            let a = center+rotate(outer, angle: Angle(degree: Double(90+90*i)))
            let b = center+rotate(arm, angle: Angle(degree: Double(90+90*i)))
            self.append(.arcTo(
                tangent: a,
                tangent: b,
                radius: radius)
            )
        }

        let restCos = (rest/2).cos
        if abs(rest.degree) > 1 {
            let a = center + Vec2d(
                radius: radius/restCos,
                angle:  Angle(degree: Double(90*count))+rest/2+lower)
            let b = center + end

            self.append(.arcTo(
                tangent: a,
                tangent: b,
                radius: radius)
            )

        }
    }
}

extension Path : Sequence {
    public typealias Iterator = IndexingIterator<Array<Segment>>
    public func makeIterator() -> Iterator {
        return segments.makeIterator()
    }
}
