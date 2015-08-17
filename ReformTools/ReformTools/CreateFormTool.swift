//
//  CreateFormTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformMath
import ReformStage

class CreateFormTool : Tool {
    enum Streight {
        case No
        case Yes(inversed: Bool)
    }
    
    enum State
    {
        case Idle
        case Delegating
        case Snapped(pos: Vec2d, startPoint: SnapPoint, cycle: Int)
        case Pressed(creating: Form)
        case PressedSnapped(creating: Form, streight: Streight, pos: Vec2d, endPoint: SnapPoint, cycle: Int)
    }
    
    var state : State = .Idle
    let stage : Stage
    let snapUI : SnapUI
    
    let selectionTool : SelectionTool
    
    init(stage: Stage, snapUI: SnapUI, selectionTool: SelectionTool) {
        self.stage = stage
        self.snapUI = snapUI
        self.selectionTool = selectionTool
    }
    
    func setUp() {
        selectionTool.setUp()
        state = .Idle
        snapUI.state = .Show(stage.getSnapPoints())
    }
    
    func tearDown() {
        snapUI.state = .Hide
        selectionTool.tearDown()
    }
    
    func refresh() {
        snapUI.state = .Show(stage.getSnapPoints())
        
        selectionTool.refresh()
    }
    
    func focusChange() {
        
        selectionTool.focusChange()
    }
    
    func process(input: Input, withModifiers modifiers: [Modifier]) {
        switch input {
        case .Cancel:
            switch self.state {
            case .Delegating:
                selectionTool.process(input, withModifiers: modifiers)
                break
            case .Pressed(let form):
                
                break
                
            case .PressedSnapped(let form):
                
                break
                
            case .Idle, .Snapped:
                break
            }
            break
        case .Cycle:
            switch self.state {
            case .Delegating:
                selectionTool.process(input, withModifiers: modifiers)
                break
            case .Snapped(let pos, _, let cycle):
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Snapped(pos: pos, startPoint: snapPoint, cycle: cycle + 1)
                } else {
                    state = .Idle
                }
                
                break
            case .PressedSnapped(_):
                break
            case .Idle, .Pressed(_):
                break
            }
            break
        case .Move(let position):
            switch self.state {
            case .Idle:
                if let snapPoint = snapPointNear(position) {
                    state = .Snapped(pos: position, startPoint: snapPoint, cycle: 0)
                }
                break
            case .Snapped(let position, _, let cycle):
                if let snapPoint = snapPointNear(position, index: cycle) {
                    state = .Snapped(pos: position, startPoint: snapPoint, cycle: cycle+1)
                } else {
                    state = .Idle
                }
                break
            case .Pressed(_):
                break
            case .PressedSnapped(_):
                break
            case .Delegating:
                selectionTool.process(input, withModifiers: modifiers)
                break
            }
            break
        case .Press:
            switch self.state {
            case .Snapped:
                break
            case .Pressed(_), .PressedSnapped(_), .Idle, .Delegating:
                state = .Delegating
                selectionTool.process(input, withModifiers: modifiers)
                break
            }
            break
        case .Release:
            switch self.state {
            case .Pressed(_):
                break
            case .PressedSnapped(_):
                break
            case .Delegating:
                state = .Idle
                selectionTool.process(input, withModifiers: modifiers)
                break
            case .Idle, .Snapped:
                state = .Delegating
                selectionTool.process(input, withModifiers: modifiers)
                break
            }
            break
        case .Toggle:
            switch self.state {
            case .PressedSnapped(_):
                break
            case .Idle, .Snapped, .Pressed(_), .Delegating:
                break
            }
            break
            
        }
    }
    
    func excludeEntity(entity: Entity) -> Bool {
        switch state {
        case .Pressed(let form):
            return form.identifier == entity.id
        case .PressedSnapped(let form, _, _, _, _):
            return form.identifier == entity.id
        default:
            return false
        }
    }
    
    func snapPointNear(position: Vec2d, index: Int = 0) -> SnapPoint? {
        let points = stage.getSnapPoints({_ in true}, excludePoint: {
            return distance(point: $0.position, point: position) > 10
        })
        
        return points.count < 1 ? nil : points[index % points.count]
    }
}