//
//  MoveTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

class MoveTool : Tool {
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
    
    init(stage: Stage, grabUI: GrabUI, snapUI: SnapUI) {
        self.stage = stage
        self.grabUI = grabUI
        self.snapUI = snapUI
    }
    
    func setUp() {
    }
    
    func tearDown() {
        grabUI.state = .Hide
        snapUI.state = .Hide
    }
    
    func refresh() {
    }
    
    func focusChange() {
    }
    
    func process(input: Input, withModifiers: [Modifier]) {
    }
}