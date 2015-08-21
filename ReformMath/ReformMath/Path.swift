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

extension Segment {
    var length : Double {
        switch self {
        case .Line(let line):
            return line.length
        case .Arc(let arc):
            return arc.length
        }
    }
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

func pointOn(segment: Segment, closestTo: Vec2d, maxDistance: Double) -> (Double, Vec2d)? {
    switch segment {
    case .Line(let line):
        let end = line.to - line.from
        let p = closestTo - line.from
        
        guard end.length != 0 else { return nil }
        
        let normEnd = end / end.length
        
        let projected = project(p, onto: end)
        let u = dot(p, normEnd) / end.length
        
        guard case (0...1) = u else {
            return nil
        }
        
        guard (projected-p).length <= maxDistance else {
            return nil
        }

        return (u, line.from+projected)
    case .Arc:
        return nil
    }
}

public func pointOn(segmentPath path: SegmentPath, closestTo: Vec2d, maxDistance: Double) -> (Double, Vec2d)? {
    let result = path.reduce((0.0, Optional<(Double, Vec2d)>.None)) { prev, segment in

        
        if let (t, p) = pointOn(segment, closestTo: closestTo, maxDistance : maxDistance) {
            if let (_, pp) = prev.1 where (closestTo-pp).length < (closestTo-p).length {
                return (prev.0 + segment.length, prev.1)
            }
            return (prev.0 + segment.length, (prev.0 + t*segment.length, p))
        }
        
        return (prev.0 + segment.length, prev.1)
    }
    
    return result.1.map { (u,p) in return ((u/result.0), p) }
}