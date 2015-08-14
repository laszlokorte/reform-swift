//
//  BasicPointRotator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

struct BasicPointRotator : Rotator {
    private let points : [WriteableRuntimePoint]
    
    init(points:WriteableRuntimePoint...) {
        self.points = points
    }
    
    
    func rotate(runtime: Runtime, angle: Angle, fix: Vec2d) {
        for point in points {
            if let oldPos = point.getPositionFor(runtime) {
                let delta = oldPos - fix
                
                point.setPositionFor(runtime, position: fix + ReformMath.rotate(delta, angle: angle))
            }
        }
    }
}