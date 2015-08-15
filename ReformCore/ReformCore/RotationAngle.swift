//
//  RotationAngle.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeRotationAngle : Degeneratable {
    func getAngleFor(runtime: Runtime) -> Angle?
}

public protocol WriteableRuntimeRotationAngle : RuntimeRotationAngle {
    func setAngleFor(runtime: Runtime, angle: Angle)
}