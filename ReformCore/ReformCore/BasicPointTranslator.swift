//
//  BasicPointTranslator.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct BasicPointTranslator : Translator {
    private let points : [WriteableRuntimePoint]
    
    init(points:WriteableRuntimePoint...) {
        self.points = points
    }
    
    func translate(runtime: Runtime, delta: Vec2d) {
        for p in points {
            if let oldPos = p.getPositionFor(runtime) {
                p.setPositionFor(runtime, position: oldPos + delta)
            }
        }
    }
}