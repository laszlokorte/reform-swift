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
        case Moving(point: EntityPoint, node: InstructionNode, target: Target, offset: Vec2d)
    }
    
    var state : State = .Idle
    var snapType : PointType = []
    
    let stage : Stage
    let pointGrabber : PointGrabber
    let pointSnapper : PointSnapper
    let streightener : Streightener
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
        self.streightener = Streightener()
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
        case .Moving(_, let node, _, _):
            focus.current = node.previous
            node.removeFromParent()
            state = .Idle;

            notifier()
        }
        
    }
    
    public func process(input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        snapType = modifier.contains(.Glomp) ? [.Glomp] : [.Form, .Intersection]
        
        if modifier.isStreight {
            streightener.enable()
        } else {
            streightener.disable()
        }
        
        
        switch state {
        case .Delegating:
            selectionTool.process(input, atPosition: pos, withModifier: modifier)
            switch input {
            case .ModifierChange, .Press,
            .Move, .Cycle, .Toggle:
                break
            case .Release:
                state = .Idle
            }
        case .Idle:
            switch input {
            case .Move, .ModifierChange:
                pointGrabber.searchAt(pos)
            case .Press:
                if let grabbedPoint = pointGrabber.current {
                
                    guard let currentInstruction = self.focus.current else {
                        break
                    }
                    let distance = ConstantDistance(delta: Vec2d())
                    let instruction = TranslateInstruction(formId: grabbedPoint.formId, distance: distance)
                    let node = InstructionNode(instruction: instruction)
                    
                    if currentInstruction.append(sibling: node) {
                        focus.current = node
                        
                        state = .Moving(point: grabbedPoint, node: node, target: .Free(position: pos), offset: pos - grabbedPoint.position)
                        
                        pointSnapper.enable(.Except(grabbedPoint.formId), pointType: snapType)
                    }
                } else {
                    
                    state = .Delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .Cycle:
                pointGrabber.cycle()
            case .Toggle, .Release:
                break
            }
        case .Moving(let grabPoint, let node, _, let offset):
            switch input {
                
            case .ModifierChange:
                pointSnapper.enable(.Except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .Moving(point: grabPoint, node: node, target: pointSnapper.getTarget(pos), offset: offset)
            case .Press:
                break
            case .Release:
                state = .Idle
                pointSnapper.disable()
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle:
                pointSnapper.cycle()
                state = .Moving(point: grabPoint, node: node, target: pointSnapper.getTarget(pos), offset: offset)
            case .Toggle:
                streightener.invert()
            }
        }
        
        if let entity = selection.selected {
            pointGrabber.enable(entity)
        } else {
            pointGrabber.disable()
        }
        
        publish()
    }
    
    private func publish() {
        if case .Moving(let activePoint, let node, let target, let offset) = state {
            let distance : protocol<RuntimeDistance, Labeled>
            switch target {
            case .Free(let position):
                distance = ConstantDistance(delta: streightener.adjust(position - activePoint.position - offset))
            case .Snap(let snap):
                distance = RelativeDistance(from: activePoint.runtimePoint, to: snap.runtimePoint, direction: streightener.directionFor(snap.position - activePoint.position))
            }
            
            node.replaceWith(TranslateInstruction(formId: activePoint.formId, distance: distance))
            notifier()
        }
    }
    
}