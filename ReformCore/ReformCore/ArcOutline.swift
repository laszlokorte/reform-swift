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
    
    func getPositionFor(runtime: Runtime, t: Double) -> Vec2d? {
        guard let c = center.getPositionFor(runtime),
            let rad = radius.getLengthFor(runtime),
            let a1 = angleA.getAngleFor(runtime),
            let a2 = angleB.getAngleFor(runtime) else {
                return nil
        }
        
        return c + rotate(Vec2d.XAxis * rad, angle: lerp(t, a: a1, b: a2))
    }
    
    func getLengthFor(runtime: Runtime) -> Double? {
        guard let rad = radius.getLengthFor(runtime),
            let a1 = angleA.getAngleFor(runtime),
            let a2 = angleB.getAngleFor(runtime) else {
            return nil
        }
                
        return 2 * M_PI * rad * (a2-a1).percent/100
    }
    
    func getSegmentsFor(runtime: Runtime) -> SegmentPath {
        guard let r = radius.getLengthFor(runtime),
            let c = center.getPositionFor(runtime),
            let a1 = angleA.getAngleFor(runtime),
            let a2 = angleB.getAngleFor(runtime) else {
                return []
        }
        
        return [Segment.Arc(Arc2d(center: c, radius: r, start: a1, end:a2))]
    }
}