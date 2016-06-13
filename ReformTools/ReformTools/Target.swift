//
//  Target.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public enum Target {
    case free(position: Vec2d)
    case snap(point: SnapPoint)
}
