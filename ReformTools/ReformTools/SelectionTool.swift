//
//  SelectionTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

public class SelectionTool : Tool {
    enum State
    {
        case Idle
        case Snapped
    }
    
    var state : State = .Idle
    let stage : Stage
    let selectionUI : SelectionUI
    
    public init(stage: Stage, selectionUI: SelectionUI) {
        self.stage = stage
        self.selectionUI = selectionUI
    }
    
    public func setUp() {
    }
    
    public func tearDown() {
        selectionUI.state = .Hide
    }
    
    public func refresh() {
    }
    
    public func focusChange() {
    }
    
    public func process(input: Input, withModifiers: [Modifier]) {
    }
}