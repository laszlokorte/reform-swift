//
//  BasicLengthScaler.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct BasicLengthScaler : Scaler {
    private let length : WriteableRuntimeLength
    private let angle : RuntimeRotationAngle
    private let offset : Angle
    
    init(length: WriteableRuntimeLength, angle: RuntimeRotationAngle, offset: Angle = Angle(degree: 0)) {
        self.length = length
        self.angle = angle
        self.offset = offset
    }
    
    
    func scale(runtime : Runtime, factor: Double, fix: Vec2d, axis: Vec2d) {
        if (axis.x == 0 && axis.y == 0)
        {
            if let oldLength = length.getLengthFor(runtime) {
                length.setLengthFor(runtime, length: oldLength * factor)
            }
        }
        else
        {
            if let oldLength = length.getLengthFor(runtime),
                let angleValue = angle.getAngleFor(runtime) {
                
                    let p = rotate(Vec2d(x:oldLength, y:0), angle: angleValue - offset)
                
                    let delta = p - fix
                    
                    let projected = project(delta, onto: axis)
                    
                    let scaled = delta + projected * (factor - 1)
                    
                    length.setLengthFor(runtime, length: scaled.length)
            }
        }
    }
}