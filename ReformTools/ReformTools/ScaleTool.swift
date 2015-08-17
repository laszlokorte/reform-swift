//
//  ScaleTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

class ScaleTool : Tool {
    enum State
    {
        case Idle
        case PressedIdle
        case Snapped
        case Pressed
    }
    
    var state : State = .Idle
    let stage : Stage
    let handleUI : HandleUI
    let pivotUI : PivotUI
    
    init(stage: Stage, handleUI: HandleUI, pivotUI: PivotUI) {
        self.stage = stage
        self.handleUI = handleUI
        self.pivotUI = pivotUI
    }
    
    func setUp() {
    }
    
    func tearDown() {
        handleUI.state = .Hide
        pivotUI.state = .Hide
    }
    
    func refresh() {
    }
    
    func focusChange() {
    }
    
    func process(input: Input, withModifiers: [Modifier]) {
    }
}