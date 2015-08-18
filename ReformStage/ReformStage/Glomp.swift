//
//  Glomp.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore

public struct GlompPoint : SnapPoint {
    public let position : Vec2d
    public let label : String
    let point : ReformCore.GlompPoint
    
    public init(position: Vec2d, label: String, point: ReformCore.GlompPoint) {
        self.position = position
        self.label = label
        self.point = point
    }
    
    public var runtimePoint : LabeledPoint {
        return point
    }
}