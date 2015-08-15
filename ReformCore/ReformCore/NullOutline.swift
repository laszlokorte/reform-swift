//
//  NullOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct NullOutline : Outline {    
    func getPositionFor(runtime: Runtime, t: Double) -> Vec2d? {
        return nil
    }
    
    func getLengthFor(runtime: Runtime) -> Double? {
        return nil
    }
    
    func getSegmentsFor(runtime: Runtime) -> [Segment] {
        return []
    }
}