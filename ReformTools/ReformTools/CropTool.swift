//
//  CropTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformStage

public class CropTool : Tool {
    enum State
    {
        case Idle
        case Hover
        case Pressed
    }
    
    var state : State = .Idle
    let stage : Stage
    let cropUI : CropUI
    
    public init(stage: Stage, cropUI: CropUI) {
        self.stage = stage
        self.cropUI = cropUI
    }

    
    public func setUp() {
    }
    
    public func tearDown() {
        cropUI.state = .Hide
    }
    
    public func refresh() {
    }
    
    public func focusChange() {
    }
    
    public func process(input: Input, withModifier: Modifier) {
    }
}