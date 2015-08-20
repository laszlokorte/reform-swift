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
        case Snapped(startPoint: SnapPoint)
        case Started(startPoint: SnapPoint, form: Form, node: InstructionNode, target: Target, alignment: AlignmentMode)
        case Delegating

    }
    
    var state : State = .Idle
    
    var snapType : PointType = [.Form, .Intersection]
    
    var cursorPoint = Vec2d()
    
    let entityFinder : EntityFinder
    let focus : InstructionFocus
    let selection : FormSelection
    let notifier : ChangeNotifier
    
    let selectionTool : SelectionTool
    
    let pointSnapper : PointSnapper
    let pointGrabber : PointGrabber
    
    var idSequence : Int64 = 199
    
    public init(stage: Stage, focus: InstructionFocus, selection: FormSelection, snapUI: SnapUI, grabUI: GrabUI, selectionTool: SelectionTool, notifier: ChangeNotifier) {
        self.entityFinder = EntityFinder(stage: stage)
        self.focus = focus
        self.selection = selection
        self.selectionTool = selectionTool
        self.notifier = notifier
        
        self.pointSnapper = PointSnapper(stage: stage, snapUI: snapUI, radius: 10)
        self.pointGrabber = PointGrabber(stage: stage, grabUI: grabUI, radius: 10)
    }
    
    public func setUp() {
        selectionTool.setUp()
        state = .Idle
        pointSnapper.enable(.Any, pointType: snapType)
        pointGrabber.disable()
    }
    
    public func tearDown() {
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
            pointGrabber.disable()
                        
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
            case .ModifierChange:
                pointSnapper.enable(.Any, pointType: snapType)
                break
            case .Release:
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle, .Toggle, .Move, .Press:
                break
            }
            break
        case .Idle:
            switch input {
            case .ModifierChange:
                pointSnapper.enable(.Any, pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if let snapPoint = pointSnapper.current {
                    state = .Snapped(startPoint: snapPoint)
                }
                break
            case .Press:
                self.state = .Delegating
                selectionTool.process(input, atPosition: pos,  withModifier: modifier)
                break
            case .Release, .Cycle, .Toggle:
                break
            }
            break
        case .Started(let startPoint, let form, let node, let target, _):
            switch input {
            case .ModifierChange:
                pointSnapper.enable(.Except(form.identifier), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if let snapPoint = pointSnapper.current {
                    state = .Started(
                        startPoint: startPoint,
                        form: form, node: node,
                        target: .Snap(
                            point: snapPoint,
                            streightening: modifier.isStreight ? .Orthogonal(inverted: target.isStreighteningInverted) : .None
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
            case .Release:
                state = .Idle
                pointSnapper.enable(.Any, pointType: snapType)
                process(.Move, atPosition: pos, withModifier: modifier)
                pointGrabber.disable()
                break
            case .Cycle:
                pointSnapper.cycle()
                if let snapPoint = pointSnapper.current {
                    state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Snap(
                            point: snapPoint,
                            streightening: modifier.isStreight ?  .Orthogonal(inverted: target.isStreighteningInverted) : .None
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
                if case .Snap(let targetPoint, _) = target {
                    self.state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Snap(
                            point: targetPoint,
                            streightening: modifier.isStreight ?
                                .Orthogonal(inverted: !target.isStreighteningInverted) : .None
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned
                    )
                }
                break
                
            case .Press:
                break
            }
            
            break
        case .Snapped(let startPoint):
            switch input {
            case .ModifierChange:
                pointSnapper.enable(.Any, pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if let snapPoint = pointSnapper.current {
                    state = .Snapped(
                        startPoint: snapPoint
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
                            streightening: modifier.isStreight ? .Orthogonal(inverted: false) : .None),
                        alignment: modifier.altAlign ? .Centered : .Aligned)
                    
                
                    selection.selected = form.identifier
                    pointSnapper.enable(
                        .Except(form.identifier), pointType: snapType
                    )
                    
                    pointGrabber.enable(form.identifier)
                    
                }
                
                break
            case .Cycle:
                pointSnapper.cycle()
                if let snapPoint = pointSnapper.current {
                    state = .Snapped(
                        startPoint: snapPoint
                    )
                } else {
                    state = .Idle
                }

                break
            case .Toggle, .Release:
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
                
            case .Snap(let snapPoint, let streightening):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint, direction: streightening.directionFor(snapPoint.position - start.position), alignment: alignment.runtimeAlignment)

            }
            
            node.replaceWith(CreateFormInstruction(form: form, destination: destination))
            
            notifier()
        }
        
        print(state)
    }
    
}
