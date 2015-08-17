//
//  MorphTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

class MorphTool : Tool {
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
    let handleUI : HandleUI
    let snapUI : SnapUI
    
    init(stage: Stage, handleUI: HandleUI, snapUI: SnapUI) {
        self.stage = stage
        self.handleUI = handleUI
        self.snapUI = snapUI
    }
    
    func setUp() {
    }
    
    func tearDown() {
        handleUI.state = .Hide
        snapUI.state = .Hide
    }
    
    func refresh() {
    }
    
    func focusChange() {
    }
    
    func process(input: Input, withModifiers: [Modifier]) {
    }
}