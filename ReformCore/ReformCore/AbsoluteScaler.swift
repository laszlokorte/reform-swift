//
//  AbsoluteScaler.swift
//  ReformCore
//
//  Created by Laszlo Korte on 22.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct AbsoluteScaler : Scaler {
    private let scaler : Scaler
    
    init(scaler: Scaler) {
        self.scaler = scaler
    }
    
    
    func scale<R:Runtime>(_ runtime: R, factor: Double, fix: Vec2d, axis: Vec2d) {
        scaler.scale(runtime, factor: abs(factor), fix: fix, axis: axis)
    }
}
