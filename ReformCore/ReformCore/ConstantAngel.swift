//
//  ConstantAngel.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct ConstantAngle : RuntimeRotationAngle, Labeled {
    private let angle: Angle
    
    public init(angle: Angle = Angle()) {
        self.angle = angle
    }
    
    public func getAngleFor<R:Runtime>(runtime: R) -> Angle? {
        return angle
    }
    
    public func getDescription(stringifier: Stringifier) -> String {
        return String(format: "%.2f%%", angle.percent)
    }

    public var isDegenerated : Bool {
        return angle.radians == 0
    }
}

extension ConstantAngle : Equatable {
}

public func ==(lhs: ConstantAngle, rhs: ConstantAngle) -> Bool {
    return lhs.angle == rhs.angle
}

func combine(angle a: ConstantAngle, angle b: ConstantAngle) -> ConstantAngle {
    return ConstantAngle(angle: a.angle + b.angle)
}