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
    public let position : Vec2d
    public let label : String
    let point : RuntimeIntersectionPoint
    
    public var runtimePoint : LabeledPoint {
        return point
    }
    
}

extension IntersectionSnapPoint {
    public var formIdA : FormIdentifier {
        return point.formA
    }
    
    public var formIdB : FormIdentifier {
        return point.formB
    }
}