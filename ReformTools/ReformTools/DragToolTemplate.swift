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
    var formId : SourceIdentifier { get }
}

public protocol DragToolProtocol {
    associatedtype StartType : Positioned
    associatedtype InstructionType : Instruction
    
    func instructionForDrag(_ from: StartType, to: Target, offset: Vec2d) -> InstructionType
    
    func refresh()

    func reset()
    
    func filterStart(_ formId: FormIdentifier?)
    
    func searchStart(_ at: Vec2d)
    func cycleStart()
    
    var start : StartType? { get }
}

enum State<StartType>
{
    case idle
    case delegating
    case dragging(start: StartType, target: Target, offset: Vec2d)
}

public final class DragTool<Delegate: DragToolProtocol> {

    
    var delegate : Delegate
    var state : State<Delegate.StartType> = .idle
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
        state = .idle
        selectionTool.setUp()
    }
    
    public func tearDown() {
        state = .idle
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
        case .delegating, .idle:
            state = .idle
            selectionTool.cancel()
        case .dragging:
            instructionCreator.cancel()
            delegate.reset()
            state = .idle
        }
    }
    
    public func process(_ input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        snapType = modifier.contains(.Glomp) ? [.Glomp] : [.Form, .Intersection]
        
        if modifier.isStreight {
            streightener.enable()
        } else {
            streightener.disable()
        }
        
        
        switch state {
        case .delegating:
            selectionTool.process(input, atPosition: pos, withModifier: modifier)
            switch input {
            case .modifierChange, .press,
            .move, .cycle, .toggle:
                break
            case .release:
                state = .idle
            }
        case .idle:
            switch input {
            case .move, .modifierChange:
                delegate.searchStart(pos)
            case .press:
                if let grabbedPoint = delegate.start {
                    
                    let target : Target = .free(position: pos)
                    let offset = pos - grabbedPoint.position
                    let instruction = delegate.instructionForDrag(grabbedPoint, to: target, offset: offset)
                    
                    instructionCreator
                        .beginCreation(instruction)
                    
                    state = .dragging(start: grabbedPoint, target: .free(position: pos), offset: offset)
                    
                    pointSnapper.enable(.except(grabbedPoint.formId), pointType: snapType)
                    
                } else {
                    state = .delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .cycle:
                delegate.cycleStart()
            case .toggle, .release:
                break
            }
        case .dragging(let grabPoint, _, let offset):
            switch input {
                
            case .modifierChange:
                pointSnapper.enable(.except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .dragging(start: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .press:
                break
            case .release:
                instructionCreator.commit()
                state = .idle
                pointSnapper.disable()
                process(.move, atPosition: pos, withModifier: modifier)
            case .cycle:
                pointSnapper.cycle()
                state = .dragging(start: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .toggle:
                streightener.invert()
            }
        }
        
        delegate.filterStart(selection.one)
        
        publish()
    }
    
    private func publish() {
        if case .dragging(let activePoint, let target, let offset) = state {            
            instructionCreator.update(delegate.instructionForDrag(activePoint, to: target, offset: offset))
        }
    }

    
}
