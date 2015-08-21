//
//  Streightening.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath

private enum State {
    case Disabled
    case Enabled(inverted: Bool)
}

class Streightener {
    private var state : State = .Disabled
    
    func enable() {
        if case .Disabled = state  {
            state = .Enabled(inverted: false)
        }
    }
    
    func disable() {
        state = .Disabled
    }
    
    func invert() {
        if case .Enabled(let inverted) = state {
            state = .Enabled(inverted: !inverted)
        }
    }
    
    func reset() {
        if case .Enabled = state {
            state = .Enabled(inverted: false)
        }
    }
    
    func adjust(delta: Vec2d) -> Vec2d {
        switch state {
        case .Enabled:
            return project(delta, onto: rotate(Vec2d.XAxis, angle: stepped(angle(delta), size: Angle(percent: 25))))
        case .Disabled:
            return delta
        }
    }
    
    func directionFor(delta: Vec2d) -> protocol<RuntimeDirection, Labeled> {
        switch state {
        case .Disabled:
            return FreeDirection()
        case .Enabled(let inverted):
            return (abs(delta.x) > abs(delta.y)) != inverted ? Cartesian.Horizontal : Cartesian.Vertical
        }
    }
}