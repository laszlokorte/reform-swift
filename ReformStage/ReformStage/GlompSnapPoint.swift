//
//  GlompSnapPoint.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore

public struct GlompSnapPoint : SnapPoint, Equatable {
    public let position : Vec2d
    public let label : String
    let point : GlompPoint
    
    public init(position: Vec2d, label: String, point: ReformCore.GlompPoint) {
        self.position = position
        self.label = label
        self.point = point
    }
    
    public var runtimePoint : LabeledPoint {
        return point
    }
    
    public func belongsTo(formId: FormIdentifier) -> Bool {
        return point.formId == formId
    }
}

public func ==(lhs: GlompSnapPoint, rhs: GlompSnapPoint) -> Bool {
    return lhs.position == rhs.position && lhs.label == rhs.label && lhs.point == rhs.point
}