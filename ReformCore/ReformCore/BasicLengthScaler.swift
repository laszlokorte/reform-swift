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
        if let oldLength = length.getLengthFor(runtime),
            let angleValue = angle.getAngleFor(runtime) {
            
            let p = rotate(Vec2d(x:oldLength, y:0), angle: angleValue + offset)
        
            let projected = project(p, onto: axis)
                
            let scaled = oldLength + projected.length * (factor - 1) * signum(oldLength)
            
            length.setLengthFor(runtime, length: scaled)
        }
    }
}