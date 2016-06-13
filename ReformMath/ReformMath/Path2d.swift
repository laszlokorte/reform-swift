//
//  Path2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 22.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public typealias SegmentPath = [Segment]

public enum Segment {
    case line(LineSegment2d)
    case arc(Arc2d)
}

extension Segment {
    var length : Double {
        switch self {
        case .line(let line):
            return line.length
        case .arc(let arc):
            return arc.length
        }
    }
}
