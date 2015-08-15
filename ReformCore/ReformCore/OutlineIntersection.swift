//
//  OutlineIntersection.swift
//  ReformCore
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public enum Segment {
    case Line(LineSegment2d)
    case Arc(Arc2d)
}

public func intersect(segment segmentA: Segment, and segmentB: Segment) -> [Vec2d] {
    switch (segmentA, segmentB) {
    case (.Line(let a), .Line(let b)):
        return intersect(line: a, line: b).map({[$0]}) ?? []
    case (.Arc(let a), .Arc(let b)):
        return intersect(arc: a, arc: b)
    case (.Line(let a), .Arc(let b)):
        return intersect(line: a, arc: b)
    case (.Arc(let a), .Line(let b)):
        return intersect(line: b, arc: a)
    }
}
