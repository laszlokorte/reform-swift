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
        case .Started(_,_,_,.Free(_, true), _): return "Started Free Streight"
        case .Started(_,_,_,.Free(_, false), _): return "Started Free"
        case .Started(_,_,_,.Snap(_,_,_,.Orthogonal), _): return "Started Snapped Orthogonal"
        case .Started(_,_,_,.Snap(_,_,_,.None), _): return "Started Snapped"
        case .Delegating: return "Delegating"
        }
    }
    
}

public class CreateFormTool : Tool {

    enum StreighteningMode {
        case None
        case Orthogonal(inverted: Bool)
        
        var isInverted : Bool {
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
        case Snap(position: Vec2d, point: SnapPoint, cycle: Int, streightening: StreighteningMode)
    }
    
    enum State
    {
        case Idle
        case Snapped(pos: Vec2d, startPoint: SnapPoint, cycle: Int)
        case Started(startPoint: SnapPoint, form: Form, node: InstructionNode, target: Target, alignment: AlignmentMode)
        case Delegating

    }
    
    var state : State = .Idle {
        didSet {
            update(state)
        }
    }
    let stage : Stage
    let focus : InstructionFocus
    let snapUI : SnapUI
    let notifier : ChangeNotifier
    
    let selectionTool : SelectionTool
    
    var idSequence : Int64 = 199
    
    public init(stage: Stage, focus: InstructionFocus, snapUI: SnapUI, selectionTool: SelectionTool, notifier: ChangeNotifier) {
        self.stage = stage
        self.focus = focus
        self.snapUI = snapUI
        self.selectionTool = selectionTool
        self.notifier = notifier
    }
    
    public func setUp() {
        selectionTool.setUp()
        state = .Idle
        snapUI.state = .Show(stage.getSnapPoints(excludeCurrent))
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
            case .Started(_, _, let instruction, _, _):
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
                    state = .Snapped(
                        pos: pos,
                        startPoint:
                        snapPoint, cycle: cycle + 1
                    )
                } else {
                    state = .Idle
                }
                
                break
            case .Started(let start, let form, let node, .Snap(let pos, _, let cycle, let streight), _):
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Started(
                        startPoint: start,
                        form: form,
                        node: node,
                        target: .Snap(
                            position: pos,
                            point: snapPoint,
                            cycle: cycle+1,
                            streightening: streight
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                } else {
                    state = .Started(
                        startPoint: start,
                        form: form,
                        node: node,
                        target: .Free(
                            position: pos,
                            streight: modifier.isStreight ? true : false
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                }
                break
                
            case .Idle, .Started(_):
                break
            }
            break
        case .Move(let position):
            switch self.state {
            case .Idle:
                if let snapPoint = snapPointNear(position) {
                    state = .Snapped(
                        pos: position,
                        startPoint: snapPoint,
                        cycle: 0
                    )
                }
                break
            case .Snapped(_, _, let cycle):
                if let snapPoint = snapPointNear(position, index: cycle) {
                    state = .Snapped(
                        pos: position,
                        startPoint: snapPoint,
                        cycle: cycle
                    )
                } else {
                    state = .Idle
                }
                break
            case .Started(let start, let form, let node, .Snap(_, _, let cycle, let streightening), _):
                if let snapPoint = snapPointNear(position, index: cycle) {
                    state = .Started(
                        startPoint: start,
                        form: form, node: node,
                        target: .Snap(
                            position: position,
                            point: snapPoint,
                            cycle: cycle,
                            streightening: modifier.isStreight ?
                                .Orthogonal(inverted: streightening.isInverted) : .None
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                } else {
                    state = .Started(
                        startPoint: start,
                        form: form, node: node,
                        target: .Free(
                            position: position,
                            streight: modifier.isStreight
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                }
                break
            case .Started(let start, let form, let node, .Free(_,_), _):
                if let snapPoint = snapPointNear(position) {
                    state = .Started(
                        startPoint: start,
                        form: form,
                        node: node,
                        target: .Snap(
                            position: position,
                            point: snapPoint,
                            cycle: 0,
                            streightening: modifier.isStreight ? .Orthogonal(inverted: false) : .None),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                } else {
                    state = .Started(
                        startPoint: start,
                        form: form,
                        node: node,
                        target: .Free(
                            position: position,
                            streight: modifier.isStreight),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
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
                guard let currentInstruction = self.focus.current else {
                    break
                }
                let form = LineForm(id: FormIdentifier(idSequence++), name: "Line \(idSequence)")
                let destination = FixSizeDestination(from: startPoint.runtimePoint, delta: Vec2d())
                let instruction = CreateFormInstruction(form: form, destination: destination)
                let node = InstructionNode(instruction: instruction)
                if currentInstruction.append(sibling: node) {
                    focus.current = node

                    state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Snap(
                            position: pos,
                            point: startPoint,
                            cycle: 0,
                            streightening: modifier.isStreight ? .Orthogonal(inverted: false) : .None),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                    
                }
                

//                .Free(position: pos, streight: modifiers.contains(Modifier.Shift))
                break
            case .Idle, .Delegating:
                self.state = .Delegating
                selectionTool.process(input, withModifier: modifier)
                break
            case .Started(_):
                break
            }
            break
        case .Release:
            switch self.state {
            case .Delegating:
                selectionTool.process(input, withModifier: modifier)
                state = .Idle

                break
            case .Started(_,_,_, let target, _):
                let position : Vec2d
                switch target {
                case .Free(let pos,_):
                    position = pos
                    break
                case .Snap(let pos,_,_,_):
                    position = pos
                    break
                }
                state = .Idle
                process(.Move(position: position), withModifier: modifier)
                break
            case .Idle:
                break
            case .Snapped:
                break
            }
            break
        case .Toggle:
            switch self.state {
            case .Started(let p, let f, let n, .Snap(let pos, let tp, let cycle, .Orthogonal(let inverted)), _):
                self.state = .Started(
                    startPoint: p,
                    form: f,
                    node: n,
                    target: .Snap(
                        position: pos,
                        point: tp,
                        cycle: cycle,
                        streightening: modifier.isStreight ?
                            .Orthogonal(inverted: !inverted) : .None
                    ),
                    alignment: modifier.altAlign ? .Centered : .Aligned
                )
                break
            case .Idle, .Snapped, .Started, .Delegating:
                break
            }
            break
            
            
        case .ModifierChange:
            switch self.state {
            case .Delegating:
                selectionTool.process(input, withModifier: modifier)
                break
            case .Started(let startpoint, let form, let node, let oldTarget, _):
                
                let newTarget : Target
                
                switch oldTarget {
                case .Free(let pos, _):
                    newTarget = .Free(position: pos, streight: modifier.isStreight)
                    break
                case .Snap(let pos, let point, let cycle, let streightMode):
                    newTarget = .Snap(
                        position: pos,
                        point: point,
                        cycle: cycle,
                        streightening: modifier.isStreight ? .Orthogonal(inverted: streightMode.isInverted) : .None)
                    break
                }
                
                state = .Started(
                    startPoint: startpoint,
                    form: form,
                    node: node,
                    target: newTarget,
                    alignment: modifier.altAlign ? .Centered : .Aligned)
                
                break
                
            case .Idle, .Snapped:
                break
            }

            break
        }
        

    }
    
    func update(state: State) {
        switch state {
        case .Idle, .Delegating:
            snapUI.state = .Show(stage.getSnapPoints(excludeCurrent))
            break
        case .Snapped(_, let start,_):
            snapUI.state = .Active(start, stage.getSnapPoints(excludeCurrent))
            break
        case .Started(let start, let form, let node, let target, let alignment):
            let destination : protocol<RuntimeInitialDestination, Labeled>
            
            switch target {
            case .Free(let targetPosition, let streight):
                let delta = adjust(targetPosition - start.position, streighten: streight)
                
                destination = FixSizeDestination(from: start.runtimePoint, delta: delta, alignment: alignment.runtimeAlignment)
                snapUI.state = .Show(stage.getSnapPoints(excludeCurrent))

            case .Snap(_, let snapPoint, _, let streighteningMode):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint, direction: direction(streighteningMode, delta: snapPoint.position - start.position), alignment: alignment.runtimeAlignment)
                
                snapUI.state = .Active(snapPoint, stage.getSnapPoints(excludeCurrent))
            }
            
            node.replaceWith(CreateFormInstruction(form: form, destination: destination))
            
            notifier()

            break
        }
    }
    
    private func excludeCurrent(id: FormIdentifier) -> Bool {
        switch state {
        case .Started(_, let form, _, _, _):
            return form.identifier == id
        default:
            return false
        }
    }
    
    private func snapPointNear(position: Vec2d, index: Int = 0) -> SnapPoint? {
        let points = stage.getSnapPoints(excludeCurrent, excludePoint: { p in
            return distance(point: p.position, point: position) > 10
        })
        
        return points.count < 1 ? nil : points[index % points.count]
    }
    
    private func adjust(delta: Vec2d, streighten: Bool) -> Vec2d {
        guard streighten else {
            return delta
        }
        
        return project(delta, onto: rotate(Vec2d.XAxis, angle: stepped(angle(delta), size: Angle(percent: 25))))
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
