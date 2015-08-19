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
        case Delegating
        case Snapped
        case Moving
    }
    
    var state : State = .Idle
    let stage : Stage
    let grabUI : GrabUI
    let snapUI : SnapUI
    let selectionTool : SelectionTool
    
    public init(stage: Stage, grabUI: GrabUI, snapUI: SnapUI, selectionTool: SelectionTool) {
        self.stage = stage
        self.grabUI = grabUI
        self.snapUI = snapUI
        self.selectionTool = selectionTool
    }
    
    public func setUp() {
        state = .Idle
        selectionTool.setUp()
    }
    
    public func tearDown() {
        state = .Idle
        grabUI.state = .Hide
        snapUI.state = .Hide
        selectionTool.tearDown()
    }
    
    public func refresh() {
        selectionTool.refresh()
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        selectionTool.cancel()
    }
    
    public func process(input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        switch state {
        case .Delegating:
            selectionTool.process(input, atPosition: pos, withModifier: modifier)
            switch input {
            case .Move:
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                break
            case .Cycle:
                break
            case .Toggle:
                break
            case .ModifierChange:
                break
            }
        case .Idle:
            switch input {
            case .Move:
                break
            case .Press:
                state = .Delegating
                selectionTool.process(input, atPosition: pos, withModifier: modifier)
                break
            case .Release:
                break
            case .Cycle:
                break
            case .Toggle:
                break
            case .ModifierChange:
                break
            }
            break
        case .Snapped:
            switch input {
            case .Move:
                break
            case .Press:
                break
            case .Release:
                break
            case .Cycle:
                break
            case .Toggle:
                break
            case .ModifierChange:
                break
            }
            break
        case .Moving:
            switch input {
            case .Move:
                break
            case .Press:
                break
            case .Release:
                break
            case .Cycle:
                break
            case .Toggle:
                break
            case .ModifierChange:
                break
            }
            break
        }
    }
}