//
//  MorphTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage

public final class MorphTool : Tool {
    enum State
    {
        case idle
        case delegating
        case moving(handle: Handle, target: Target, offset: Vec2d)
    }
    
    var state : State = .idle
    var snapType : PointType = []
    
    let stage : Stage
    let handleGrabber : HandleGrabber
    let pointSnapper : PointSnapper
    let streightener : Streightener
    let instructionCreator : InstructionCreator
    
    let selectionTool : SelectionTool
    let selection : FormSelection
    
    public init(stage: Stage, selection: FormSelection, pointSnapper: PointSnapper, handleGrabber: HandleGrabber, streightener: Streightener, instructionCreator: InstructionCreator, selectionTool: SelectionTool) {
        self.stage = stage
        self.selection = selection
        self.selectionTool = selectionTool
        
        
        self.pointSnapper = pointSnapper
        self.handleGrabber = handleGrabber
        self.streightener = streightener
        self.instructionCreator = instructionCreator
    }
    
    public func setUp() {
        state = .idle
        selectionTool.setUp()
        if let selected = selection.one {
            handleGrabber.enable(selected)
        }
    }
    
    public func tearDown() {
        instructionCreator.cancel()
        pointSnapper.disable()
        handleGrabber.disable()
        selectionTool.tearDown()
        state = .idle
    }
    
    public func refresh() {
        pointSnapper.refresh()
        handleGrabber.refresh()
        selectionTool.refresh()
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        switch self.state {
        case .delegating, .idle:
            state = .idle
            selectionTool.cancel()
        case .moving:
            instructionCreator.cancel()
            pointSnapper.disable()
            state = .idle
        }
    }
    
    public func process(_ input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        snapType = modifier.contains(.Glomp) ? (modifier.contains(.Free) ? [.Grid] : [.Glomp]) :modifier.contains(.Free) ? [.None] :  [.Form, .Intersection]
        
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
                handleGrabber.searchAt(pos)
            case .press:
                if let grabbedHandle = handleGrabber.current {
                    
                    let distance = ConstantDistance(delta: Vec2d())
                    let instruction = MorphInstruction(formId: grabbedHandle.formId.runtimeId, anchorId: grabbedHandle.anchorId, distance: distance)
                    
                    instructionCreator
                        .beginCreation(instruction)
                    
                    state = .moving(handle: grabbedHandle, target: .free(position: pos), offset: pos - grabbedHandle.position)
                    
                    pointSnapper.enable(.except(grabbedHandle.formId), pointType: snapType)
                    
                } else {
                    state = .delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .cycle:
                handleGrabber.cycle()
            case .toggle, .release:
                break
            }
        case .moving(let grabbedHandle, _, let offset):
            switch input {
                
            case .modifierChange:
            pointSnapper.enable(.except(grabbedHandle.formId), pointType: snapType)
                fallthrough
            case .move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .moving(handle: grabbedHandle, target: pointSnapper.getTarget(pos), offset: offset)
            case .press:
                break
            case .release:
                instructionCreator.commit()
                state = .idle
                pointSnapper.disable()
                process(.move, atPosition: pos, withModifier: modifier)
            case .cycle:
                pointSnapper.cycle()
                state = .moving(handle: grabbedHandle, target: pointSnapper.getTarget(pos), offset: offset)
            case .toggle:
                streightener.invert()
            }
        }
        
        if let entity = selection.one {
            handleGrabber.enable(entity)
        } else {
            handleGrabber.disable()
        }
        
        publish()
    }
    
    private func publish() {
        if case .moving(let grabbedHandle, let target, let offset) = state {
            let distance : RuntimeDistance & Labeled
            switch target {
            case .free(let position):
                distance = ConstantDistance(delta: streightener.adjust(position - grabbedHandle.position - offset, step: Angle(degree: 90)))
            case .snap(let snap):
                distance = RelativeDistance(from: grabbedHandle.runtimePoint, to: snap.runtimePoint, direction: streightener.directionFor(snap.position - grabbedHandle.position))
            }
            
            instructionCreator.update(MorphInstruction(formId: grabbedHandle.formId.runtimeId, anchorId: grabbedHandle.anchorId, distance: distance))
        }
    }
}
