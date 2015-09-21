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

    func isEqualTo(other: RuntimeRotationAngle) -> Bool
}

public protocol WriteableRuntimeRotationAngle : RuntimeRotationAngle {
    func setAngleFor<R:Runtime>(runtime: R, angle: Angle)
}



extension RuntimeRotationAngle where Self : Equatable {
    public func isEqualTo(other: RuntimeRotationAngle) -> Bool {
        guard let other = other as? Self else {
            return false
        }

        return self == other
    }
}