//
//  DragToolTemplate.swift
//  ReformTools
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage

public protocol Positioned {
    var position : Vec2d { get }
    var formId : FormIdentifier { get }
}

public protocol DragToolProtocol {
    typealias StartType : Positioned
    
    func instructionForDrag(from: StartType, to: Target, offset: Vec2d) -> Instruction
    
    func refresh()

    func reset()
    
    func filterStart(formId: FormIdentifier?)
    
    func searchStart(at: Vec2d)
    func cycleStart()
    
    var start : StartType? { get }
}

enum State<StartType>
{
    case Idle
    case Delegating
    case Dragging(start: StartType, target: Target, offset: Vec2d)
}

public final class DragTool<Delegate: DragToolProtocol> {

    
    var delegate : Delegate
    var state : State<Delegate.StartType> = .Idle
    var snapType : PointType = []
    
    let stage : Stage
    let pointSnapper : PointSnapper
    let streightener : Streightener
    let instructionCreator : InstructionCreator
    
    let selectionTool : SelectionTool
    let selection : FormSelection
    
    public init(delegate: Delegate, stage: Stage, selection: FormSelection, pointSnapper: PointSnapper, pointGrabber: PointGrabber, streightener: Streightener, instructionCreator: InstructionCreator, selectionTool: SelectionTool) {
        self.delegate = delegate
        self.stage = stage
        self.selection = selection
        self.selectionTool = selectionTool
        
        self.pointSnapper = pointSnapper
        self.streightener = streightener
        self.instructionCreator = instructionCreator
    }
    
    public func setUp() {
        state = .Idle
        selectionTool.setUp()
    }
    
    public func tearDown() {
        state = .Idle
        delegate.refresh()
        selectionTool.tearDown()
    }
    
    public func refresh() {
        delegate.refresh()

        selectionTool.refresh()
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        switch self.state {
        case .Delegating, .Idle:
            state = .Idle
            selectionTool.cancel()
        case .Dragging:
            instructionCreator.cancel()
            delegate.reset()
            state = .Idle;
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
                delegate.searchStart(pos)
            case .Press:
                if let grabbedPoint = delegate.start {
                    
                    let target : Target = .Free(position: pos)
                    let offset = pos - grabbedPoint.position
                    let instruction = delegate.instructionForDrag(grabbedPoint, to: target, offset: offset)
                    
                    instructionCreator
                        .beginCreation(instruction)
                    
                    state = .Dragging(start: grabbedPoint, target: .Free(position: pos), offset: offset)
                    
                    pointSnapper.enable(.Except(grabbedPoint.formId), pointType: snapType)
                    
                } else {
                    state = .Delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .Cycle:
                delegate.cycleStart()
            case .Toggle, .Release:
                break
            }
        case .Dragging(let grabPoint, _, let offset):
            switch input {
                
            case .ModifierChange:
                pointSnapper.enable(.Except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .Dragging(start: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .Press:
                break
            case .Release:
                instructionCreator.commit()
                state = .Idle
                pointSnapper.disable()
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle:
                pointSnapper.cycle()
                state = .Dragging(start: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .Toggle:
                streightener.invert()
            }
        }
        
        delegate.filterStart(selection.one)
        
        publish()
    }
    
    private func publish() {
        if case .Dragging(let activePoint, let target, let offset) = state {            
            instructionCreator.update(delegate.instructionForDrag(activePoint, to: target, offset: offset))
        }
    }

    
}