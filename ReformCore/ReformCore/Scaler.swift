//
//  Scaler.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Scaler {
    func scale(runtime : Runtime, factor: Double, fix: Vec2d, axis: Vec2d)
}