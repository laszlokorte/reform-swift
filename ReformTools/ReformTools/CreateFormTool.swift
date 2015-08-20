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
    
    var snapType : PointType = []
    
    var cursorPoint = Vec2d()
    
    let entityFinder : EntityFinder
    let focus : InstructionFocus
    let selection : FormSelection
    let grabUI : GrabUI
    let notifier : ChangeNotifier
    
    let selectionTool : SelectionTool
    
    let pointSnapper : PointSnapper
    
    var idSequence : Int64 = 199
    
    public init(stage: Stage, focus: InstructionFocus, selection: FormSelection, snapUI: SnapUI, grabUI: GrabUI, selectionTool: SelectionTool, notifier: ChangeNotifier) {
        self.entityFinder = EntityFinder(stage: stage)
        self.focus = focus
        self.selection = selection
        self.grabUI = grabUI
        self.selectionTool = selectionTool
        self.notifier = notifier
        
        self.pointSnapper = PointSnapper(stage: stage, snapUI: snapUI, radius: 10)
    }
    
    public func setUp() {
        selectionTool.setUp()
        state = .Idle
        pointSnapper.enable(.Any, pointType: snapType)
        grabUI.state = .Hide
        
        update()
    }
    
    public func tearDown() {
        pointSnapper.disable()
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
            case .ModifierChange:
                pointSnapper.enable(.Any, pointType: snapType)
                break
            case .Move:
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
            case .Release:
                break
            case .Cycle:
                break
            case .Toggle:
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
                    let streightening : StreighteningMode
                    
                    if !modifier.isStreight {
                        streightening = .None
                    } else if case .Snap(_, let oldStreightening) = target {
                        streightening = .Orthogonal(inverted: oldStreightening.isInverted)
                    }else {
                        streightening = .Orthogonal(inverted: false)
                    }
                    
                    state = .Started(
                        startPoint: startPoint,
                        form: form, node: node,
                        target: .Snap(
                            point: snapPoint,
                            streightening: streightening
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
                pointSnapper.enable(.Any, pointType: snapType)
                process(.Move, atPosition: pos, withModifier: modifier)
                break
            case .Cycle:
                pointSnapper.cycle()
                if let snapPoint = pointSnapper.current {
                    let streightening : StreighteningMode
                    
                    if !modifier.isStreight {
                        streightening = .None
                    } else if case .Snap(_, let oldStreightening) = target {
                            streightening = .Orthogonal(inverted: oldStreightening.isInverted)
                    }else {
                        streightening = .Orthogonal(inverted: false)
                    }
                
                    state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Snap(
                            point: snapPoint,
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
                if case .Snap(let targetPoint, let streightening) = target {
                    self.state = .Started(
                        startPoint: startPoint,
                        form: form,
                        node: node,
                        target: .Snap(
                            point: targetPoint,
                            streightening: modifier.isStreight ?
                                .Orthogonal(inverted: !streightening.isInverted) : .None
                        ),
                        alignment: modifier.altAlign ? .Centered : .Aligned
                    )
                }
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
                    
                }
                
                pointSnapper.enable(.Except(form.identifier), pointType: snapType)


                break
            case .Release:
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
                
            case .Snap(let snapPoint, let streightening):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint, direction: streightening.directionFor(snapPoint.position - start.position), alignment: alignment.runtimeAlignment)

            }
            
            node.replaceWith(CreateFormInstruction(form: form, destination: destination))
            
            notifier()
        } else {
            update()
        }
        
        print(state)
    }
    
    func update() {
        switch state {
        case .Idle, .Delegating:
            grabUI.state = .Hide

            break
        case .Snapped(let start):
            grabUI.state = .Hide

            break
        case .Started(_, let form, _, let target, _):

            if let entity = entityFinder.getEntity(form.identifier) {
                selection.selected = entity.id
                grabUI.state = .Show(entity.points)
            } else {
                grabUI.state = .Hide
            }
            
            break
        }
    }
    
    
}
