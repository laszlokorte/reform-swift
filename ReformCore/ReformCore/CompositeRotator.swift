//
//  CompositeRotator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct CompositeRotator : Rotator {
    private let rotators : [Rotator]
    
    init(rotators:Rotator...) {
        self.rotators = rotators
    }
    
    
    func rotate(runtime: Runtime, angle: Angle, fix: Vec2d) {
        for rotator in rotators {
            rotator.rotate(runtime, angle: angle, fix: fix)
        }
    }
}