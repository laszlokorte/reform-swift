//
//  LineOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct LineOutline : Outline {
    private let start : RuntimePoint
    private let end : RuntimePoint
    
    init(start: RuntimePoint, end:RuntimePoint) {
        self.start = start
        self.end = end
    }
    
    func getPositionFor<R:Runtime>(runtime: R, t: Double) -> Vec2d? {
        guard let
            a = start.getPositionFor(runtime),
            b = end.getPositionFor(runtime) else {
                return nil
        }
        
        return lerp(t, a: a, b:b)
    }
    
    func getLengthFor<R:Runtime>(runtime: R) -> Double? {
        guard let
            a = start.getPositionFor(runtime),
            b = end.getPositionFor(runtime) else {
                return nil
        }
        
        return (b-a).length
    }
    
    func getSegmentsFor<R:Runtime>(runtime: R) -> SegmentPath {
        guard let
            from = start.getPositionFor(runtime),
            to = end.getPositionFor(runtime) else {
                return []
        }
        
        return [.Line(LineSegment2d(from: from, to: to))]
    }

    func getAABBFor<R : Runtime>(runtime: R) -> AABB2d? {
        guard let
            from = start.getPositionFor(runtime),
            to = end.getPositionFor(runtime) else {
                return nil
        }

        return AABB2d(min: min(from, to), max: max(from, to))
    }
}