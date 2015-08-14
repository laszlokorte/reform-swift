//
//  BasicAngleRotator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct BasicAngleRotator : Rotator {
    private let angles : [WriteableRuntimeRotationAngle]
    
    init(angles:WriteableRuntimeRotationAngle...) {
        self.angles = angles
    }
    
    
    func rotate(runtime: Runtime, angle: Angle, fix: Vec2d) {
        for a in angles {
            if let old = a.getAngleFor(runtime) {
                a.setAngleFor(runtime, angle: old + angle)
            }
        }
    }
}