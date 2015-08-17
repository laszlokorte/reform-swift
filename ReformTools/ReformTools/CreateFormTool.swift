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

    enum Target {
        case Free(position: Vec2d, streight: Bool)
        case Snap(position: Vec2d, point: SnapPoint, cycle : Int)
    }
    
    enum State
    {
        case Idle
        case Delegating
        case Snapped(pos: Vec2d, startPoint: SnapPoint, cycle: Int)
        case Pressed(startPoint: SnapPoint, creating: Form, instruction: InstructionNode, target: Target)
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
                state = .Idle
                selectionTool.process(input, withModifiers: modifiers)
                break
            case .Pressed(_, _, let instruction, _):
                state = .Idle;
                
                instruction.removeFromParent()
                snapUI.state = .Show(stage.getSnapPoints())
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
            case .Pressed(let start, let form, let instruction, .Snap(let pos, _, let cycle)):
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Snap(position: pos, point: snapPoint, cycle: cycle+1))
                } else {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Free(position: pos, streight: modifiers.contains(Modifier.Shift)))
                }
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
            case .Pressed(let start, let form, let instruction, .Snap(let pos, _, let cycle)):
                if let snapPoint = snapPointNear(pos, index: cycle) {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Snap(position: pos, point: snapPoint, cycle: cycle))
                } else {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Free(position: position, streight: modifiers.contains(Modifier.Shift)))
                }
                break
            case .Pressed(let start, let form, let instruction, .Free(_,_)):
                if let snapPoint = snapPointNear(position) {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Snap(position: position, point: snapPoint, cycle: 0))
                } else {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Free(position: position, streight: modifiers.contains(Modifier.Shift)))
                }
                break
            case .Delegating:
                selectionTool.process(input, withModifiers: modifiers)
                break
            }
            break
        case .Press:
            switch self.state {
            case .Snapped(let pos, let startPoint,_):
                let form = LineForm(id: FormIdentifier(999), name: "Line 42")
                let destination = FixSizeDestination(from: startPoint.runtimePoint, delta: Vec2d())
                let instruction = CreateFormInstruction(form: form, destination: destination)
                let node = InstructionNode(instruction: instruction)
                state = .Pressed(startPoint: startPoint, creating: form, instruction: node, target: .Free(position: pos, streight: modifiers.contains(Modifier.Shift)))
                break
            case .Idle, .Delegating:
                state = .Delegating
                selectionTool.process(input, withModifiers: modifiers)
                break
            case .Pressed(_):
                break
            }
            break
        case .Release:
            switch self.state {
            case .Pressed(_):
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
            case .Pressed(_, _, _, .Snap(_)):
                break
            case .Idle, .Snapped, .Pressed(_), .Delegating:
                break
            }
            break
            
        }
        
        update(state)
    }
    
    func update(state: State) {
        switch state {
        case .Idle, .Delegating, .Snapped:
            break
        case .Pressed(let start, let form, let node, let target):
            let destination : protocol<RuntimeInitialDestination, Labeled>
            
            switch target {
            case .Free(let targetPosition, let streight):
                let offset = start.position - targetPosition
                let delta = targetPosition - start.position
                destination = FixSizeDestination(from: start.runtimePoint, delta: delta)
            case .Snap(_, let snapPoint, _):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint)
            }
            
            node.replaceWith(CreateFormInstruction(form: form, destination: destination))
            break
        }
    }
    
    func excludeEntity(entity: Entity) -> Bool {
        switch state {
        case .Pressed(_, let form, _, _):
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