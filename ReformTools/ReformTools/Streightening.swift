//
//  Streightening.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

enum StreighteningMode {
    case None
    case Orthogonal(inverted: Bool)
    
    var isInverted : Bool {
        if case .Orthogonal(let inverted) = self {
            return inverted
        } else {
            return false
        }
    }
}

extension StreighteningMode {
    func directionFor(delta: Vec2d) -> protocol<RuntimeDirection, Labeled> {
        switch self {
        case .None:
            return FreeDirection()
        case .Orthogonal(let inverted):
            return (abs(delta.x) > abs(delta.y)) != inverted ? Cartesian.Horizontal : Cartesian.Vertical
        }
    }
}

func adjust(delta: Vec2d, streighten: Bool) -> Vec2d {
    guard streighten else {
        return delta
    }
    
    return project(delta, onto: rotate(Vec2d.XAxis, angle: stepped(angle(delta), size: Angle(percent: 25))))
}