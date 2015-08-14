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
        guard let c = center.getPositionFor(runtime),
            let rad = radius.getLengthFor(runtime),
            let a = angle.getAngleFor(runtime) else {
            return nil
        }
        
        return c + rotate(Vec2d(x: rad, y:0), angle: a)
    }
    
    func getLengthFor(runtime: Runtime) -> Double? {
        guard let rad = radius.getLengthFor(runtime) else {
            return nil
        }
        
        return 2 * M_PI * rad
    }
}