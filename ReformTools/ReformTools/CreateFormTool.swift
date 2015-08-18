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

extension CreateFormTool.State : CustomDebugStringConvertible {

    var debugDescription : String{
        switch self {
        case .Idle: return "Idle"
        case .Snapped: return "Snapped"
        case .Pressed(_,_,_,.Free(_, true), _): return "Pressed Free Streight"
        case .Pressed(_,_,_,.Free(_, false), _): return "Pressed Free"
        case .Pressed(_,_,_,.Snap(_,_,_,.Orthogonal), _): return "Pressed Snapped Orthogonal"
        case .Pressed(_,_,_,.Snap(_,_,_,.None), _): return "Pressed Snapped"
        case .Delegating: return "Delegating"
        }
    }
    
}

public class CreateFormTool : Tool {

    enum StreighteningMode {
        case None
        case Orthogonal(inverted: Bool)
        
        var inverted : Bool {
            if case .Orthogonal(let inverted) = self {
                return inverted
            } else {
                return false
            }
        }
    }
    
    enum AlignmentMode {
        case Centered
        case Aligned
        
        var runtimeAlignment : RuntimeAlignment {
            switch self {
            case .Centered: return .Centered
            case .Aligned: return .Leading
            }
        }
    }
    
    enum Target {
        case Free(position: Vec2d, streight: Bool)
        case Snap(position: Vec2d, point: SnapPoint, cycle: Int, StreighteningMode)
    }
    
    enum State
    {
        case Idle
        case Snapped(pos: Vec2d, startPoint: SnapPoint, cycle: Int)
        case Pressed(startPoint: SnapPoint, creating: Form, instruction: InstructionNode, target: Target, alignment: AlignmentMode)
        case Delegating

    }
    
    var state : State = .Idle {
        didSet {
            update(state)
        }
    }
    let stage : Stage
    let snapUI : SnapUI
    
    let selectionTool : SelectionTool
    
    public init(stage: Stage, snapUI: SnapUI, selectionTool: SelectionTool) {
        self.stage = stage
        self.snapUI = snapUI
        self.selectionTool = selectionTool
    }
    
    public func setUp() {
        selectionTool.setUp()
        state = .Idle
        snapUI.state = .Show(stage.getSnapPoints())
    }
    
    public func tearDown() {
        snapUI.state = .Hide
        selectionTool.tearDown()
    }
    
    public func refresh() {
        update(state)
        
        selectionTool.refresh()
    }
    
    public func focusChange() {
        
        selectionTool.focusChange()
    }
    
    public func process(input: Input, withModifier modifier: Modifier) {
        switch input {
        case .Cancel:
            switch self.state {
            case .Delegating:
                state = .Idle
                selectionTool.process(input, withModifier: modifier)
                break
            case .Pressed(_, _, let instruction, _, _):
                state = .Idle;
                
                instruction.removeFromParent()
                break
                
            case .Idle, .Snapped:
                break
            }
            break
        case .Cycle:
            switch self.state {
            case .Delegating:
                selectionTool.process(input, withModifier: modifier)
                break
            case .Snapped(let pos, _, let cycle):
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Snapped(pos: pos, startPoint: snapPoint, cycle: cycle + 1)
                } else {
                    state = .Idle
                }
                
                break
            case .Pressed(let start, let form, let instruction, .Snap(let pos, _, let cycle, let streight), _):
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Snap(position: pos, point: snapPoint, cycle: cycle+1, streight), alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                } else {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Free(position: pos, streight: modifier.contains(Modifier.Shift) ? true : false), alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
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
            case .Snapped(_, _, let cycle):
                if let snapPoint = snapPointNear(position, index: cycle) {
                    state = .Snapped(pos: position, startPoint: snapPoint, cycle: cycle)
                } else {
                    state = .Idle
                }
                break
            case .Pressed(let start, let form, let instruction, .Snap(_, _, let cycle, let streightening), _):
                if let snapPoint = snapPointNear(position, index: cycle) {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Snap(position: position, point: snapPoint, cycle: cycle, modifier.contains(.Shift) ?  .Orthogonal(inverted: streightening.inverted) : .None),  alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                } else {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Free(position: position, streight: modifier.contains(Modifier.Shift)),  alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                }
                break
            case .Pressed(let start, let form, let instruction, .Free(_,_), _):
                if let snapPoint = snapPointNear(position) {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Snap(position: position, point: snapPoint, cycle: 0, modifier.contains(.Shift) ? .Orthogonal(inverted: false) : .None),  alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                } else {
                    state = .Pressed(startPoint: start, creating: form, instruction: instruction, target: .Free(position: position, streight: modifier.contains(Modifier.Shift)),  alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                }
                break
            case .Delegating:
                selectionTool.process(input, withModifier: modifier)
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
                state = .Pressed(startPoint: startPoint, creating: form, instruction: node, target: .Snap(position: pos, point: startPoint, cycle: 0, modifier.contains(.Shift) ? .Orthogonal(inverted: false) : .None),  alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                
//                .Free(position: pos, streight: modifiers.contains(Modifier.Shift))
                break
            case .Idle, .Delegating:
                self.state = .Delegating
                selectionTool.process(input, withModifier: modifier)
                break
            case .Pressed(_):
                break
            }
            break
        case .Release:
            switch self.state {
            case .Pressed(_):
                state = .Idle
                break
            case .Delegating:
                state = .Idle
                selectionTool.process(input, withModifier: modifier)
                break
            case .Idle, .Snapped:
                state = .Delegating
                selectionTool.process(input, withModifier: modifier)
                break
            }
            break
        case .Toggle:
            switch self.state {
            case .Pressed(let p, let f, let i, .Snap(let pos, let tp, let cycle, .Orthogonal(let inverted)), _):
                self.state = .Pressed(
                    startPoint: p,
                    creating: f,
                    instruction: i,
                    target: .Snap(
                        position: pos,
                        point: tp,
                        cycle: cycle,
                        modifier.contains(Modifier.Shift) ?
                            .Orthogonal(inverted: !inverted) : .None
                    ),
                    alignment: modifier.contains(.Alt) ? .Centered : .Aligned
                )
                break
            case .Idle, .Snapped, .Pressed, .Delegating:
                break
            }
            break
            
            
        case .ModifierChange:
            switch self.state {
            case .Delegating:
                selectionTool.process(input, withModifier: modifier)
                break
            case .Pressed(let startpoint, let form, let instruction, let oldTarget, _):
                
                let newTarget : Target
                
                switch oldTarget {
                case .Free(let pos, _):
                    newTarget = .Free(position: pos, streight: modifier.contains(.Shift))
                    break
                case .Snap(let pos, let point, let cycle, let streightMode):
                    newTarget = .Snap(position: pos, point: point, cycle: cycle, modifier.contains(.Shift) ? .Orthogonal(inverted: streightMode.inverted) : .None)
                    break
                }
                
                state = .Pressed(startPoint: startpoint, creating: form, instruction: instruction, target: newTarget, alignment: modifier.contains(.Alt) ? .Centered : .Aligned)
                
                break
                
            case .Idle, .Snapped:
                break
            }

            break
        }
        
        print(self.state)

    }
    
    func update(state: State) {
        switch state {
        case .Idle, .Delegating:
            snapUI.state = .Show(stage.getSnapPoints())
            break
        case .Snapped(_, let start,_):
            snapUI.state = .Active(start, stage.getSnapPoints())
            break
        case .Pressed(let start, let form, let node, let target, let alignment):
            let destination : protocol<RuntimeInitialDestination, Labeled>
            
            switch target {
            case .Free(let targetPosition, let streight):
                let delta = adjust(targetPosition - start.position, streighten: streight)
                
                destination = FixSizeDestination(from: start.runtimePoint, delta: delta, alignment: alignment.runtimeAlignment)
                snapUI.state = .Show(stage.getSnapPoints())

            case .Snap(_, let snapPoint, _, let streighteningMode):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint, direction: direction(streighteningMode, delta: snapPoint.position - start.position), alignment: alignment.runtimeAlignment)
                
                snapUI.state = .Active(snapPoint, stage.getSnapPoints())
            }
            
            node.replaceWith(CreateFormInstruction(form: form, destination: destination))
            break
        }
    }
    
    private func excludeEntity(entity: Entity) -> Bool {
        switch state {
        case .Pressed(_, let form, _, _, _):
            return form.identifier == entity.id
        default:
            return false
        }
    }
    
    private func snapPointNear(position: Vec2d, index: Int = 0) -> SnapPoint? {
        let points = stage.getSnapPoints({_ in false}, excludePoint: { p in
            return distance(point: p.position, point: position) > 10
        })
        
        return points.count < 1 ? nil : points[index % points.count]
    }
    
    private func adjust(delta: Vec2d, streighten: Bool) -> Vec2d {
        guard streighten else {
            return delta
        }
        
        return delta
    }
    
    private func direction(mode : StreighteningMode, delta: Vec2d) -> protocol<RuntimeDirection, Labeled> {
        switch mode {
        case .None:
            return FreeDirection()
        case .Orthogonal(let inverted):
            return (abs(delta.x) > abs(delta.y)) != inverted ? Cartesian.Horizontal : Cartesian.Vertical
        }
    }
}
