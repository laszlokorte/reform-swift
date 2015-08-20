//
//  IntersectionSnapPoint.swift
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
    public let point : RuntimeIntersectionPoint
    
    public var runtimePoint : LabeledPoint {
        return point
    }

    public func belongsTo(formId: FormIdentifier) -> Bool {
        return formId == self.point.formA || formId == self.point.formB
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