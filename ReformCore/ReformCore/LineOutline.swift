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
    
    func getPositionFor<R:Runtime>(_ runtime: R, t: Double) -> Vec2d? {
        guard let
            a = start.getPositionFor(runtime),
            let b = end.getPositionFor(runtime) else {
                return nil
        }
        
        return lerp(t, a: a, b:b)
    }
    
    func getLengthFor<R:Runtime>(_ runtime: R) -> Double? {
        guard let
            a = start.getPositionFor(runtime),
            let b = end.getPositionFor(runtime) else {
                return nil
        }
        
        return (b-a).length
    }
    
    func getSegmentsFor<R:Runtime>(_ runtime: R) -> SegmentPath {
        guard let
            from = start.getPositionFor(runtime),
            let to = end.getPositionFor(runtime) else {
                return []
        }
        
        return [.line(LineSegment2d(from: from, to: to))]
    }

    func getAABBFor<R : Runtime>(_ runtime: R) -> AABB2d? {
        guard let
            from = start.getPositionFor(runtime),
            let to = end.getPositionFor(runtime) else {
                return nil
        }

        return AABB2d(min: min(from, to), max: max(from, to))
    }
}
