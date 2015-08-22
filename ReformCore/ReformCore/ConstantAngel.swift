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
    
    public func getAngleFor(runtime: Runtime) -> Angle? {
        return angle
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        return "\(angle.percent)%"
    }
    
    public func isDegenerated() -> Bool {
        return angle.radians == 0
    }
}