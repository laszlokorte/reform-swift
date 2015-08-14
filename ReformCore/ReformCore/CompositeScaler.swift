//
//  CompositeScaler.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct CompositeScaler : Scaler {
    private let scalers : [Scaler]
    
    init(scalers: Scaler...) {
        self.scalers = scalers
    }
    
    
    func scale(runtime : Runtime, factor: Double, fix: Vec2d, axis: Vec2d) {
        for scaler in scalers {
            scaler.scale(runtime, factor: factor, fix: fix, axis: axis)
        }
    }
}