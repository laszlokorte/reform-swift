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

public class CreateFormTool : Tool {
    
    enum State
    {
        case Idle
        case Snapped(startPoint: SnapPoint, cycle: Int)
        case Started(startPoint: SnapPoint, form: Form, node: InstructionNode, target: Target, alignment: AlignmentMode)
        case Delegating

    }
    
    var state : State = .Idle
    
    var snapType : PointType = []
    
    var cursorPoint = Vec2d()
    
    let pointFinder : PointFinder
    let entityFinder : EntityFinder
    let focus : InstructionFocus
    let selection : FormSelection
    let snapUI : SnapUI
    let grabUI : GrabUI
    let notifier : ChangeNotifier
    
    let selectionTool : SelectionTool
    
    var idSequence : Int64 = 199
    
    public init(stage: Stage, focus: InstructionFocus, selection: FormSelection, snapUI: SnapUI, grabUI: GrabUI, selectionTool: SelectionTool, notifier: ChangeNotifier) {
        self.pointFinder = PointFinder(stage: stage)
        self.entityFinder = EntityFinder(stage: stage)
        self.focus = focus
        self.selection = selection
        self.snapUI = snapUI
        self.grabUI = grabUI
        self.selectionTool = selectionTool
        self.notifier = notifier
    }
    
    public func setUp() {
        selectionTool.setUp()
        state = .Idle
        snapUI.state = .Show(pointFinder.getSnapPoints(pointQuery()))
        grabUI.state = .Hide
        
        update()
    }
    
    public func tearDown() {
        snapUI.state = .Hide
        grabUI.state = .Hide
        selectionTool.tearDown()
    }
    
    public func refresh() {
        update()

        selectionTool.refresh()
    }
    
    public func focusChange() {
        
        selectionTool.focusChange()
    }
    
    public func cancel() {
        switch self.state {
        case .Delegating, .Idle:
            state = .Idle
            break
        case .Started(_, _, let instruction, _, _):
            focus.current = instruction.previous
            instruction.removeFromParent()
            notifier()
            
            grabUI.state = .Hide
            
            state = .Idle;

            break
            
        case .Snapped:
            break
        }
        
        selectionTool.cancel()

    }
    
    public func process(input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        snapType = modifier.contains(.Glomp) ? [.Glomp] : [.Form, .Intersection]
        cursorPoint = pos
            
        switch state {
        case .Delegating:
            selectionTool.process(input, atPosition: pos,  withModifier: modifier)
            switch input {
            case .Move, .ModifierChange:
                if let snapPoint = snapPointNear(pos) {
                    state = .Snapped(
                        startPoint: snapPoint,
                        cycle: 0
                    )
                }
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle:
                break
            case .Toggle:
                break
            }
            break
        case .Idle:
            switch input {
            case .Move, .ModifierChange:
                if let snapPoint = snapPointNear(pos) {
                    state = .Snapped(startPoint: snapPoint, cycle: 0)
                }
                break
            case .Press:
                self.state = .Delegating
                selectionTool.process(input, atPosition: pos,  withModifier: modifier)
                break
            case .Release:
                break
            case .Cycle:
                break
            case .Toggle:
                break
            }
            break
            
        case .Started(let startPoint, let form, let node, .Free, _):
            switch input {
            case .Move, .ModifierChange:
                if let snapPoint = snapPointNear(pos) {
                    state = .Started(
                        startPoint: startPoint,
                        form: form, node: node,
                        target: .Snap(
                            point: snapPoint,
                            cycle: 0,
                            streightening: modifier.isStreight ?
                                .Orthogonal(inverted: false) : .None
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                } else {
                    state = .Started(
                        startPoint: startPoint,
                        form: form, node: node,
                        target: .Free(
                            position: pos,
                            streight: modifier.isStreight
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                }
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle:
                break
            case .Toggle:
                break
            }
            break
        case .Started(let startPoint, let form, let node, .Snap(let targetPoint, let cycle, let streightening), _):
            switch input {
            case .Move, .ModifierChange:
                if let snapPoint = snapPointNear(pos, index: cycle) {
                    state = .Started(
                        startPoint: startPoint,
                        form: form, node: node,
                        target: .Snap(
                            point: snapPoint,
                            cycle: cycle,
                            streightening: modifier.isStreight ?
                                .Orthogonal(inverted: streightening.isInverted) : .None
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                } else {
                    state = .Started(
                        startPoint: startPoint,
                        form: form, node: node,
                        target: .Free(
                            position: pos,
                            streight: modifier.isStreight
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                }
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle:
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Snap(
                            point: snapPoint,
                            cycle: cycle+1,
                            streightening: streightening
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                } else {
                    state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Free(
                            position: pos,
                            streight: modifier.isStreight ? true : false
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                }

                break
            case .Toggle:
                self.state = .Started(
                    startPoint: startPoint,
                    form: form,
                    node: node,
                    target: .Snap(
                        point: targetPoint,
                        cycle: cycle,
                        streightening: modifier.isStreight ?
                            .Orthogonal(inverted: !streightening.isInverted) : .None
                    ),
                    alignment: modifier.altAlign ? .Centered : .Aligned
                )
                break
            }
            break
        case .Snapped(let startPoint, let cycle):
            switch input {
            case .Move, .ModifierChange:
                if let snapPoint = snapPointNear(pos, index: cycle) {
                    state = .Snapped(
                        startPoint: snapPoint,
                        cycle: cycle
                    )
                } else {
                    state = .Idle
                }
                break
            case .Press:
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
                            point: startPoint,
                            cycle: 0,
                            streightening: modifier.isStreight ? .Orthogonal(inverted: false) : .None),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                    
                }

                break
            case .Release:
                break
            case .Cycle:
                if let snapPoint = snapPointNear(pos, index: cycle+1) {
                    state = .Snapped(
                        startPoint:
                        snapPoint, cycle: cycle+1
                    )
                } else {
                    state = .Idle
                }

                break
            case .Toggle:
                break
            }
            break
        }
        
        publish()
    }
    
    func publish() {
        if case .Started(let start, let form, let node, let target, let alignment) = state {
            let destination : protocol<RuntimeInitialDestination, Labeled>
            
            switch target {
            case .Free(let targetPosition, let streight):
                let delta = adjust(targetPosition - start.position, streighten: streight)
                
                destination = FixSizeDestination(from: start.runtimePoint, delta: delta, alignment: alignment.runtimeAlignment)
                snapUI.state = .Show(pointFinder.getSnapPoints(pointQuery()))
                
            case .Snap(let snapPoint, _, let streightening):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint, direction: streightening.directionFor(snapPoint.position - start.position), alignment: alignment.runtimeAlignment)
                
                snapUI.state = .Active(snapPoint, pointFinder.getSnapPoints(pointQuery()))
            }
            
            node.replaceWith(CreateFormInstruction(form: form, destination: destination))
            
            notifier()
        } else {
            update()
        }
    }
    
    func update() {
        switch state {
        case .Idle, .Delegating:
            snapUI.state = .Show(pointFinder.getSnapPoints(pointQuery()))
            grabUI.state = .Hide

            break
        case .Snapped(let start,_):
            snapUI.state = .Active(start, pointFinder.getSnapPoints(pointQuery()))
            grabUI.state = .Hide

            break
        case .Started(_, let form, _, let target, _):

            if let entity = entityFinder.getEntity(form.identifier) {
                selection.selected = entity.id
                grabUI.state = .Show(entity.points)
            } else {
                grabUI.state = .Hide
            }
            
            switch target {
            case .Free:
                snapUI.state = .Show(pointFinder.getSnapPoints(pointQuery()))
            case .Snap(let snapPoint,_,_):
                snapUI.state = .Active(snapPoint, pointFinder.getSnapPoints(pointQuery()))
            }
            
            break
        }
    }
    
    private func pointQuery() -> PointQuery {
        let filter : FormFilter
        
        switch state {
        case .Started(_, let form, _, _, _):
            filter = .Except(form.identifier)
        default:
            filter = .Any
        }
        
        return PointQuery(filter: filter, pointType: snapType, location: .Any)
    }
    
    private func handleQuery() -> PointQuery {
        let filter : FormFilter
        
        switch state {
        case .Started(_, let form, _, _, _):
            filter = .Only(form.identifier)
        default:
            filter = .None
        }
        
        return PointQuery(filter: filter, pointType: .Form, location: .Any)
    }
    
    private func pointQuery(near: Vec2d) -> PointQuery {
        let filter : FormFilter
        
        switch state {
        case .Started(_, let form, _, _, _):
            filter = .Except(form.identifier)
        default:
            filter = .Any
        }
        
        return PointQuery(filter: filter, pointType: snapType, location: .Near(near, distance: 10))
    }
    
    private func snapPointNear(position: Vec2d, index: Int = 0) -> SnapPoint? {
        let points = pointFinder.getSnapPoints(pointQuery( position))
            
        return points.count < 1 ? nil : points[index % points.count]
    }
}
