//
//  CropTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

class CropTool : Tool {
    enum State
    {
        case Idle
        case Hover
        case Pressed
    }
    
    var state : State = .Idle
    let stage : Stage
    let cropUI : CropUI
    
    init(stage: Stage, cropUI: CropUI) {
        self.stage = stage
        self.cropUI = cropUI
    }

    
    func setUp() {
    }
    
    func tearDown() {
        cropUI.state = .Hide
    }
    
    func refresh() {
    }
    
    func focusChange() {
    }
    
    func process(input: Input, withModifiers: [Modifier]) {
    }
}