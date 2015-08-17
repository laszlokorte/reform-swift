//
//  Intersection.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

public struct IntersectionSnapPoint : SnapPoint {
    let position : Vec2d
    let label : String
    let point : RuntimeIntersectionPoint
    
    var runtimePoint : LabeledPoint {
        return point
    }
    
}