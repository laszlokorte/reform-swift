//
//  MoveTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public class MoveTool : Tool {
    enum State
    {
        case Idle
        case PressedIdle
        case Snapped
        case Pressed
        case PressedSnapped
    }
    
    var state : State = .Idle
    let stage : Stage
    let grabUI : GrabUI
    let snapUI : SnapUI
    
    public init(stage: Stage, grabUI: GrabUI, snapUI: SnapUI) {
        self.stage = stage
        self.grabUI = grabUI
        self.snapUI = snapUI
    }
    
    public func setUp() {
    }
    
    public func tearDown() {
        grabUI.state = .Hide
        snapUI.state = .Hide
    }
    
    public func refresh() {
    }
    
    public func focusChange() {
    }
    
    public func process(input: Input, atPosition: Vec2d, withModifier: Modifier) {
    }
}