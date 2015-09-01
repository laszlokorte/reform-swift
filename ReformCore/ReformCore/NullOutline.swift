//
//  NullOutline.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct NullOutline : Outline {    
    func getPositionFor<R:Runtime>(runtime: R, t: Double) -> Vec2d? {
        return nil
    }
    
    func getLengthFor<R:Runtime>(runtime: R) -> Double? {
        return nil
    }
    
    func getSegmentsFor<R:Runtime>(runtime: R) -> SegmentPath {
        return []
    }
}