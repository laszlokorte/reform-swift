//
//  NullOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct NullOutline : Outline {    
    func getPositionFor<R:Runtime>(_ runtime: R, t: Double) -> Vec2d? {
        return nil
    }
    
    func getLengthFor<R:Runtime>(_ runtime: R) -> Double? {
        return nil
    }
    
    func getSegmentsFor<R:Runtime>(_ runtime: R) -> SegmentPath {
        return []
    }

    func getAABBFor<R:Runtime>(_ runtime: R) -> AABB2d? {
        return nil
    }
}
