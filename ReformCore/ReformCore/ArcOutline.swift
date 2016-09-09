//
//  ArcOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 22.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct ArcOutline : Outline {
    private let center : RuntimePoint
    private let radius : RuntimeLength
    private let angleA : RuntimeRotationAngle
    private let angleB : RuntimeRotationAngle
    
    init(center: RuntimePoint, radius:RuntimeLength, angleA: RuntimeRotationAngle, angleB: RuntimeRotationAngle) {
        self.center = center
        self.radius = radius
        self.angleA = angleA
        self.angleB = angleB
    }
    
    func getPositionFor<R:Runtime>(_ runtime: R, t: Double) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            let rad = radius.getLengthFor(runtime),
            let a1 = angleA.getAngleFor(runtime),
            let a2 = angleB.getAngleFor(runtime) else {
                return nil
        }
        
        let a = normalize360(a2-a1)
        
        return c + rotate(Vec2d.XAxis * rad, angle: a1 + t*a)
    }
    
    func getLengthFor<R:Runtime>(_ runtime: R) -> Double? {
        guard let
            rad = radius.getLengthFor(runtime),
            let a1 = angleA.getAngleFor(runtime),
            let a2 = angleB.getAngleFor(runtime)
        else {
            return nil
        }
                
        return 2 * M_PI * rad * normalize360(a2-a1).percent/100
    }
    
    func getSegmentsFor<R:Runtime>(_ runtime: R) -> SegmentPath {
        guard let
            r = radius.getLengthFor(runtime),
            let c = center.getPositionFor(runtime),
            let a1 = angleA.getAngleFor(runtime),
            let a2 = angleB.getAngleFor(runtime) else {
                return []
        }
        
        return [Segment.arc(Arc2d(center: c, radius: r, range: AngleRange(start: a1, end:a2)))]
    }

    func getAABBFor<R : Runtime>(_ runtime: R) -> AABB2d? {
        guard let
            r = radius.getLengthFor(runtime).map(abs),
            let c = center.getPositionFor(runtime) else {
                return nil
        }

        let h = Vec2d(x:r,y:r)
        return AABB2d(min: c - h, max: c + h)
    }
}
