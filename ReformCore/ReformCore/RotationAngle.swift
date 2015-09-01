//
//  RotationAngle.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public protocol RuntimeRotationAngle : Degeneratable {
    func getAngleFor<R:Runtime>(runtime: R) -> Angle?
}

public protocol WriteableRuntimeRotationAngle : RuntimeRotationAngle {
    func setAngleFor<R:Runtime>(runtime: R, angle: Angle)
}