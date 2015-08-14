//
//  Outline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol Outline {
    func getPositionFor(runtime: Runtime, t: Double) -> Vec2d?
    
    func getLengthFor(runtime: Runtime) -> Double?
}