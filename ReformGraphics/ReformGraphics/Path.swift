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
    
    mutating func reset() {
        segments.removeAll()
        segments.append(.MoveTo(Vec2d()))
    }
    
    mutating func append(segment: Segment) {
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

extension Path : SequenceType {
    public typealias Generator = IndexingGenerator<Array<Segment>>
    public func generate() -> Generator {
        return segments.generate()
    }
}