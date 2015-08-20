//
//  MoveTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage

public class MoveTool : Tool {

    
    enum State
    {
        case Idle
        case Delegating
        case Snapped(point: EntityPoint, cycle: Int)
        case Moving(point: EntityPoint, node: InstructionNode, target: Target, offset: Vec2d)
    }
    
    var state : State = .Idle
    var snapType : PointType = []
    
    var cursorPoint = Vec2d()
    
    let stage : Stage
    let grabUI : GrabUI
    let snapUI : SnapUI
    let selectionTool : SelectionTool
    let selection : FormSelection
    let pointFinder : PointFinder
    let focus : InstructionFocus
    
    let notifier : ChangeNotifier
    
    public init(stage: Stage, selection: FormSelection, focus: InstructionFocus, grabUI: GrabUI, snapUI: SnapUI, selectionTool: SelectionTool, notifier: ChangeNotifier) {
        self.stage = stage
        self.selection = selection
        self.focus = focus

        self.grabUI = grabUI
        self.snapUI = snapUI
        self.selectionTool = selectionTool
        
        self.pointFinder = PointFinder(stage: stage)
        self.notifier = notifier
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
        update()
        selectionTool.refresh()
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        switch self.state {
        case .Delegating, .Idle:
            state = .Idle
            selectionTool.cancel()

            break
        case .Moving(_, let node, _, _):
            focus.current = node.previous
            node.removeFromParent()
            state = .Idle;

            notifier()
            break
            
        case .Snapped:
            selectionTool.cancel()

            break
        }
        
    }
    
    public func process(input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        snapType = modifier.contains(.Glomp) ? [.Glomp] : [.Form, .Intersection]
        cursorPoint = pos
        
        
        switch state {
        case .Delegating:
            selectionTool.process(input, atPosition: pos, withModifier: modifier)
            switch input {
            case .Move, .ModifierChange:
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
            }
        case .Idle:
            switch input {
            case .Move, .ModifierChange:
                if let grab = grabPointNear(pos) {
                    state = .Snapped(point: grab, cycle: 0)
                } else {
                    state = .Idle
                }
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
            }
            break
        case .Snapped(let snappedPoint, let cycle):
            switch input {
            case .Move, .ModifierChange:
                if let grab = grabPointNear(pos) {
                    state = .Snapped(point: grab, cycle: cycle)
                } else {
                    state = .Idle
                }
                break
            case .Press:
                guard let currentInstruction = self.focus.current else {
                    break
                }
                let distance = ConstantDistance(delta: Vec2d())
                let instruction = TranslateInstruction(formId: snappedPoint.formId, distance: distance)
                let node = InstructionNode(instruction: instruction)
                
                if currentInstruction.append(sibling: node) {
                    focus.current = node
                    
                    state = .Moving(point: snappedPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: pos - snappedPoint.position)
                    
                    print("inserted node")
                }
                break
            case .Release:
                break
            case .Cycle:
                if let grab = grabPointNear(pos, cycle: cycle+1) {
                    state = .Snapped(point: grab, cycle: cycle+1)
                } else {
                    state = .Idle
                }
                break
            case .Toggle:
                break
            }
            break
        case .Moving(let grabPoint, let node, .Snap(let snapPoint, let cycle, let streightening), let offset):
            switch input {
            case .Move, .ModifierChange:
                if let snap = snapPointNear(pos, cycle: cycle) {
                    state = .Moving(point: grabPoint, node: node, target: .Snap(point: snap, cycle: cycle, streightening: modifier.isStreight ? .Orthogonal(inverted: streightening.isInverted) : .None), offset: offset)
                } else {
                    state = .Moving(point: grabPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: offset)
                }
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle:
                if let snap = snapPointNear(pos, cycle: cycle+1) {
                    state = .Moving(point: grabPoint, node: node, target: .Snap(point: snap, cycle: cycle+1, streightening: modifier.isStreight ? .Orthogonal(inverted: streightening.isInverted) : .None), offset: offset)
                } else {
                    state = .Moving(point: grabPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: offset)
                }
                break
            case .Toggle:
                state = .Moving(point: grabPoint, node: node, target: .Snap(point: snapPoint, cycle: cycle, streightening: .Orthogonal(inverted: !streightening.isInverted)), offset: offset)
                
                break
            }
            break
        case .Moving(let grabPoint, let node, .Free, let offset):
            switch input {
            case .Move, .ModifierChange:
                if let snap = snapPointNear(pos) {
                    state = .Moving(point: grabPoint, node: node, target: .Snap(point: snap, cycle: 0, streightening: modifier.isStreight ? .Orthogonal(inverted: false) : .None), offset: offset)
                } else {
                    state = .Moving(point: grabPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: offset)
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
        }
        
        publish()
    }
    
    private func publish() {
        if case .Moving(let activePoint, let node, let target, let offset) = state {
            let distance : protocol<RuntimeDistance, Labeled>
            switch target {
            case .Free(let position, let streight):
                distance = ConstantDistance(delta: adjust(position - activePoint.position - offset, streighten: streight))
                break
            case .Snap(let snap,_,let streightening):
                distance = RelativeDistance(from: activePoint.runtimePoint, to: snap.runtimePoint, direction: streightening.directionFor(snap.position - activePoint.position))
                break
            }
            
            node.replaceWith(TranslateInstruction(formId: activePoint.formId, distance: distance))
            notifier()
        } else {
            update()
        }
    }
    
    private func update() {
        switch state {
        case .Snapped(let activePoint, _):
            grabUI.state = .Active(activePoint, grabPoints())
            snapUI.state = .Hide
            break
        case .Moving(let activePoint, let node, let target, _):
            
            if let updatedPoint = pointFinder.getUpdatedPoint(activePoint) {
                grabUI.state = .Active(updatedPoint, grabPoints())
            }
            switch target {
            case .Free:
                snapUI.state = .Show(snapPoints())
                break
            case .Snap(let snap,_,_):
                snapUI.state = .Active(snap, snapPoints())
                break
            }
            
            break
        case .Idle, .Delegating:
            snapUI.state = .Hide
            grabUI.state = .Show(grabPoints())
            break
        }
    }
    
    private func grabPoints() -> [EntityPoint] {
        return pointFinder.getSnapPoints(grabPointQuery()).flatMap {
            $0 as? EntityPoint
        }
    }
    
    private func grabPointNear(position: Vec2d, cycle: Int = 0) -> EntityPoint? {
        let points = pointFinder.getSnapPoints((grabPointQuery(position)))
        
        guard points.count > 0 else {return nil}
        
        return points[cycle % points.count] as? EntityPoint
    }
    
    private func grabPointQuery() -> PointQuery {
        if let formId = selection.selected {
            return PointQuery(filter: .Only(formId), pointType: .Form, location: .Any)
        } else {
            return PointQuery(filter: .None, pointType: .Form, location: .Any)
        }
    }
    
    private func grabPointQuery(near: Vec2d) -> PointQuery {
        if let formId = selection.selected {
            return PointQuery(filter: .Only(formId), pointType: .Form, location: .Near(near, distance: 10))
        } else {
            return PointQuery(filter: .None, pointType: .Form, location: .Near(near, distance: 10))
        }
    }
    
    private func snapPointNear(position: Vec2d, cycle: Int = 0) -> SnapPoint? {
        let points = pointFinder.getSnapPoints(snapPointQuery(position))
        
        guard points.count > 0 else {return nil}
        
        return points[cycle % points.count]
    }
    
    private func snapPoints() -> [SnapPoint] {
        return pointFinder.getSnapPoints(snapPointQuery())
    }
    
    private func snapPointQuery() -> PointQuery {
        if case .Moving(let grabPoint,_,_, _) = state {
            return PointQuery(filter: .Except(grabPoint.formId), pointType: snapType, location: .Any)
        } else {
            return PointQuery(filter: .None, pointType: snapType, location: .Any)
        }
    }
    
    private func snapPointQuery(near: Vec2d) -> PointQuery {
        if case .Moving(let grabPoint,_,_, _) = state {
            return PointQuery(filter: .Except(grabPoint.formId), pointType: snapType, location: .Near(near, distance: 10))
        } else {
            return PointQuery(filter: .None, pointType: snapType, location: .Near(near, distance: 10))
        }
    }
    
}