//
//  BasicPointRotator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct BasicPointScaler : Scaler {
    private let points : [WriteableRuntimePoint]
    
    init(points:WriteableRuntimePoint...) {
        self.points = points
    }
    
    
    func scale(runtime : Runtime, factor: Double, fix: Vec2d, axis: Vec2d) {

        for point in points {
            if let pos = point.getPositionFor(runtime) {
                let delta = pos - fix
                
                let projected = project(delta, onto: axis)
                
                let scaled = delta + projected * (factor - 1)
                
                point.setPositionFor(runtime, position: fix + scaled)
            }
        }
    }
}