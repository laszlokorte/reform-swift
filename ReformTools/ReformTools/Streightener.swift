//
//  Streightening.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath


public final class Streightener {
    private enum State {
        case disabled
        case enabled(inverted: Bool)
    }

    
    private var state : State = .disabled
    
    public init() {}
    
    func enable() {
        if case .disabled = state  {
            state = .enabled(inverted: false)
        }
    }
    
    func disable() {
        state = .disabled
    }
    
    func invert() {
        if case .enabled(let inverted) = state {
            state = .enabled(inverted: !inverted)
        }
    }
    
    func reset() {
        if case .enabled = state {
            state = .enabled(inverted: false)
        }
    }
    
    func adjust(_ delta: Vec2d, step: Angle) -> Vec2d {
        switch state {
        case .enabled:
            return project(delta, onto: rotate(Vec2d.XAxis, angle: stepped(angle(delta) + Angle(degree: 45), size: step) - Angle(degree: 45)))
        case .disabled:
            return delta
        }
    }

    func adjust(_ delta: Vec2d, keepRatioOf: Vec2d) -> Vec2d {
        switch state {
        case .enabled:
            return project(delta, onto: keepRatioOf)
        case .disabled:
            return delta
        }
    }
    
    func adjust(_ angle: Angle) -> Angle {
        switch state {
        case .enabled:
            return stepped(angle, size: Angle(percent: 1))
        case .disabled:
            return angle
        }
    }
    
    func directionFor(_ delta: Vec2d, ratio: (Int,Int)? = nil) -> RuntimeDirection & Labeled {
        switch state {
        case .disabled:
            return FreeDirection()
        case .enabled(let inverted):
            if let ratio = ratio {
                return ProportionalDirection(proportion: ratio, large: inverted)
            } else {
                return (abs(delta.x) > abs(delta.y)) != inverted ? Cartesian.horizontal : Cartesian.vertical
            }
        }
    }
    
    func axisFor(_ axis: RuntimeAxis) -> RuntimeAxis {
        switch state {
        case .disabled:
            return axis
        case .enabled:
            return .none
        }
    }
}
