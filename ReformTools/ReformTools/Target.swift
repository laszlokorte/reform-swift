//
//  Target.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

enum Target {
    case Free(position: Vec2d, streight: Bool)
    case Snap(point: SnapPoint, streightening: StreighteningMode)
}