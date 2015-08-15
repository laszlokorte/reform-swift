//
//  Glomp.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore

struct GlompPoint : SnapPoint {
    let position : Vec2d
    let label : String
    let point : ReformCore.GlompPoint
    
    var runtimePoint : LabeledPoint {
        return point
    }
}