//
//  ScaleTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public class ScaleTool : Tool {
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
    
    public init(stage: Stage, handleUI: HandleUI, pivotUI: PivotUI) {
        self.stage = stage
        self.handleUI = handleUI
        self.pivotUI = pivotUI
    }
    
    public func setUp() {
    }
    
    public func tearDown() {
        handleUI.state = .Hide
        pivotUI.state = .Hide
    }
    
    public func refresh() {
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
    }
    
    public func process(input: Input, atPosition: Vec2d, withModifier: Modifier) {
    }
}