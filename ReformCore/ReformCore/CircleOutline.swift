
//
//  CircleOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct CircleOutline : Outline {
    private let center : RuntimePoint
    private let radius : RuntimeLength
    private let angle : RuntimeRotationAngle
    
    init(center: RuntimePoint, radius:RuntimeLength, angle: RuntimeRotationAngle) {
        self.center = center
        self.radius = radius
        self.angle = angle
    }
    
    func getPositionFor<R:Runtime>(_ runtime: R, t: Double) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            let rad = radius.getLengthFor(runtime).map(abs),
            let a = angle.getAngleFor(runtime) else {
            return nil
        }
        
        return c + rotate(Vec2d(x: rad, y:0), angle: a + Angle(percent: t*100))
    }
    
    func getLengthFor<R:Runtime>(_ runtime: R) -> Double? {
        guard let rad = radius.getLengthFor(runtime).map(abs) else {
            return nil
        }
        
        return 2 * Double.pi * rad
    }
    
    func getSegmentsFor<R:Runtime>(_ runtime: R) -> SegmentPath {
        guard let
            r = radius.getLengthFor(runtime).map(abs),
            let c = center.getPositionFor(runtime),
            let a = angle.getAngleFor(runtime) else {
            return []
        }
        return [
            Segment.arc(Arc2d(center: c, radius: r, range: AngleRange(start: a, end:normalize360(a+Angle(percent: 50))))),
            Segment.arc(Arc2d(center: c, radius: r, range: AngleRange(start: normalize360(a+Angle(percent: 50)), end:normalize360(a+Angle(percent: 100)))))
        ]
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
