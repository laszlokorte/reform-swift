//
//  Path2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 22.09.15.
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