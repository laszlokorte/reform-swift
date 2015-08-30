//
//  Path.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct Path {
    var winding : WindingRule = .NonZero
    var segments : [Segment] = [.MoveTo(Vec2d())]
    
    public init(segments: Segment...) {
        self.segments += segments
    }
    
    public mutating func reset() {
        segments.removeAll()
        segments.append(.MoveTo(Vec2d()))
    }
    
    public mutating func append(segment: Segment) {
        segments.append(segment)
    }

    public enum Segment {
        case MoveTo(Vec2d)
        case LineTo(Vec2d)
        case QuadraticTo(Vec2d, control: Vec2d)
        case QubicTo(Vec2d, control: Vec2d, control: Vec2d)
        case ArcTo(tangent: Vec2d, tangent: Vec2d, radius: Double)
        case Close
    }
    
    enum WindingRule {
        case EvenOdd
        case NonZero
    }
}

extension Path {
    public init(center: Vec2d, radius: Double, lower: Angle, upper: Angle) {
        let arm = Vec2d(radius: radius, angle: lower)
        let end = Vec2d(radius: radius, angle: upper)
        let outer = Vec2d(radius: radius*sqrt(2), angle: lower + Angle(degree: -45))
        let count = abs(Int(normalize360(upper-lower).degree / 90))
        let rest = Angle(degree: normalize360(upper-lower).degree % 90)


        self.append(.MoveTo(center+arm))
        for i in 0..<count {
            let a = center+rotate(outer, angle: Angle(degree: Double(90+90*i)))
            let b = center+rotate(arm, angle: Angle(degree: Double(90+90*i)))
            self.append(.ArcTo(
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

            self.append(.ArcTo(
                tangent: a,
                tangent: b,
                radius: radius)
            )

        }
    }
}

extension Path : SequenceType {
    public typealias Generator = IndexingGenerator<Array<Segment>>
    public func generate() -> Generator {
        return segments.generate()
    }
}