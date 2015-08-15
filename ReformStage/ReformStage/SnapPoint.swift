//
//  SnapPoint.swift
//  ReformStage
//
//  Created by Laszlo Korte on 15.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore

protocol SnapPoint {
    var position :  Vec2d { get }
    var label : String { get }
    
    var runtimePoint : LabeledPoint { get }
}