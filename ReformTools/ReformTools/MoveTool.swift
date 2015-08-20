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
        case Snapped(point: EntityPoint)
        case Moving(point: EntityPoint, node: InstructionNode, target: Target, offset: Vec2d)
    }
    
    var state : State = .Idle
    var snapType : PointType = []
    
    var cursorPoint = Vec2d()
    
    let stage : Stage
    let pointGrabber : PointGrabber
    let pointSnapper : PointSnapper
    let selectionTool : SelectionTool
    let selection : FormSelection
    let focus : InstructionFocus
    
    let notifier : ChangeNotifier
    
    public init(stage: Stage, selection: FormSelection, focus: InstructionFocus, grabUI: GrabUI, snapUI: SnapUI, selectionTool: SelectionTool, notifier: ChangeNotifier) {
        self.stage = stage
        self.selection = selection
        self.focus = focus
        self.selectionTool = selectionTool
        
        self.notifier = notifier
        
        self.pointSnapper = PointSnapper(stage: stage, snapUI: snapUI, radius: 10)
        self.pointGrabber = PointGrabber(stage: stage, grabUI: grabUI, radius: 10)
    }
    
    public func setUp() {
        state = .Idle
        selectionTool.setUp()
    }
    
    public func tearDown() {
        state = .Idle
        pointSnapper.disable()
        pointGrabber.disable()
        selectionTool.tearDown()
    }
    
    public func refresh() {
        update()
        pointSnapper.refresh()
        pointGrabber.refresh()
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
            case .ModifierChange:
                fallthrough
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
            }
            if let entity = selection.selected {
                pointGrabber.enable(entity)
            }
            break
        case .Idle:
            switch input {
            case .Move, .ModifierChange:
                pointGrabber.searchAt(pos)
                if let grab = pointGrabber.current {
                    state = .Snapped(point: grab)
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
        case .Snapped(let snappedPoint):
            switch input {
            case .Move, .ModifierChange:
                pointGrabber.searchAt(pos)
                if let grab = pointGrabber.current {
                    state = .Snapped(point: grab)
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
                    
                    pointSnapper.enable(.Except(snappedPoint.formId), pointType: snapType)
                }
                break
            case .Release:
                break
            case .Cycle:
                pointGrabber.cycle()
                
                if let grab = pointGrabber.current {
                    state = .Snapped(point: grab)
                } else {
                    state = .Idle
                }
                break
            case .Toggle:
                break
            }
            break
        case .Moving(let grabPoint, let node, .Snap(let snapPoint, let streightening), let offset):
            switch input {
                
            case .ModifierChange:
                pointSnapper.enable(.Except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)

                if let snap = pointSnapper.current {
                    state = .Moving(point: grabPoint, node: node, target: .Snap(point: snap, streightening: modifier.isStreight ? .Orthogonal(inverted: streightening.isInverted) : .None), offset: offset)
                } else {
                    state = .Moving(point: grabPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: offset)
                }
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                pointSnapper.disable()
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle:
                pointSnapper.cycle()
                if let snap = pointSnapper.current {
                    state = .Moving(point: grabPoint, node: node, target: .Snap(point: snap,  streightening: modifier.isStreight ? .Orthogonal(inverted: streightening.isInverted) : .None), offset: offset)
                } else {
                    state = .Moving(point: grabPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: offset)
                }
                break
            case .Toggle:
                state = .Moving(point: grabPoint, node: node, target: .Snap(point: snapPoint,streightening: .Orthogonal(inverted: !streightening.isInverted)), offset: offset)
                
                break
            }
            break
        case .Moving(let grabPoint, let node, .Free, let offset):
            switch input {
            case .ModifierChange:
                pointSnapper.enable(.Except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if let snap = pointSnapper.current {
                    state = .Moving(point: grabPoint, node: node, target: .Snap(point: snap,streightening: modifier.isStreight ? .Orthogonal(inverted: false) : .None), offset: offset)
                } else {
                    state = .Moving(point: grabPoint, node: node, target: .Free(position: pos, streight: modifier.isStreight), offset: offset)
                }
                break
            case .Press:
                break
            case .Release:
                state = .Idle
                pointSnapper.disable()
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
            case .Snap(let snap,let streightening):
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
       
    }

    
    
    
}