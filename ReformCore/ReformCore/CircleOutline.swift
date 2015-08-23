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
    
    func getPositionFor(runtime: Runtime, t: Double) -> Vec2d? {
        guard let
            c = center.getPositionFor(runtime),
            rad = radius.getLengthFor(runtime).map(abs),
            a = angle.getAngleFor(runtime).map(normalize360) else {
            return nil
        }
        
        return c + rotate(Vec2d(x: rad, y:0), angle: a + Angle(percent: t*100))
    }
    
    func getLengthFor(runtime: Runtime) -> Double? {
        guard let rad = radius.getLengthFor(runtime).map(abs) else {
            return nil
        }
        
        return 2 * M_PI * rad
    }
    
    func getSegmentsFor(runtime: Runtime) -> SegmentPath {
        guard let
            r = radius.getLengthFor(runtime).map(abs),
            c = center.getPositionFor(runtime),
            a = angle.getAngleFor(runtime).map(normalize360) else {
            return []
        }
        return [
            Segment.Arc(Arc2d(center: c, radius: r, start: a, end:normalize360(a+Angle(percent: 50)))),
            Segment.Arc(Arc2d(center: c, radius: r, start: normalize360(a+Angle(percent: 50)), end:normalize360(a+Angle(percent: 100))))
        ]
    }
}