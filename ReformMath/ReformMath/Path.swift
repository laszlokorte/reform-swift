//
//  Path.swift
//  ReformMath
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public typealias SegmentPath = [Segment]

public enum Segment {
    case Line(LineSegment2d)
    case Arc(Arc2d)
}

public func intersect(segment segmentA: Segment, and segmentB: Segment) -> [Vec2d] {
    switch (segmentA, segmentB) {
    case (.Line(let a), .Line(let b)):
        return intersection(line: a, line: b).map({[$0]}) ?? []
    case (.Arc(let a), .Arc(let b)):
        return intersections(arc: a, arc: b)
    case (.Line(let a), .Arc(let b)):
        return intersections(line: a, arc: b)
    case (.Arc(let a), .Line(let b)):
        return intersections(line: b, arc: a)
    }
}

public func intersect(segmentPath pathA: SegmentPath, and pathB: SegmentPath) -> [Vec2d] {
    
    var result = [Vec2d]()
    
    for segmentA in pathA {
        for segmentB in pathB {
            result += intersect(segment: segmentA, and: segmentB)
        }
    }
    
    return result
}