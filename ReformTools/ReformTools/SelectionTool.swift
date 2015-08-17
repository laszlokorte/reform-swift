//
//  SelectionTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

class SelectionTool : Tool {
    enum State
    {
        case Idle
        case Snapped
    }
    
    var state : State = .Idle
    let stage : Stage
    let selectionUI : SelectionUI
    
    init(stage: Stage, selectionUI: SelectionUI) {
        self.stage = stage
        self.selectionUI = selectionUI
    }
    
    func setUp() {
    }
    
    func tearDown() {
        selectionUI.state = .Hide
    }
    
    func refresh() {
    }
    
    func focusChange() {
    }
    
    func process(input: Input, withModifiers: [Modifier]) {
    }
}