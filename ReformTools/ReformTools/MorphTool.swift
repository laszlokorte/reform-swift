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

public class MorphTool : Tool {
    enum State
    {
        case Idle
        case Delegating
        case Moving(handle: Handle, target: Target, offset: Vec2d)
    }
    
    var state : State = .Idle
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
        state = .Idle
        selectionTool.setUp()
        if let selected = selection.selected {
            handleGrabber.enable(selected)
        }
    }
    
    public func tearDown() {
        instructionCreator.cancel()
        pointSnapper.disable()
        handleGrabber.disable()
        selectionTool.tearDown()
        state = .Idle
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
        case .Delegating, .Idle:
            state = .Idle
            selectionTool.cancel()
        case .Moving:
            instructionCreator.cancel()
            pointSnapper.disable()
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
                handleGrabber.searchAt(pos)
            case .Press:
                if let grabbedHandle = handleGrabber.current {
                    
                    let distance = ConstantDistance(delta: Vec2d())
                    let instruction = MorphInstruction(formId: grabbedHandle.formId, anchorId: grabbedHandle.anchorId, distance: distance)
                    
                    instructionCreator
                        .beginCreation(instruction)
                    
                    state = .Moving(handle: grabbedHandle, target: .Free(position: pos), offset: pos - grabbedHandle.position)
                    
                    pointSnapper.enable(.Except(grabbedHandle.formId), pointType: snapType)
                    
                } else {
                    state = .Delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .Cycle:
                handleGrabber.cycle()
            case .Toggle, .Release:
                break
            }
        case .Moving(let grabbedHandle, _, let offset):
            switch input {
                
            case .ModifierChange:
            pointSnapper.enable(.Except(grabbedHandle.formId), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .Moving(handle: grabbedHandle, target: pointSnapper.getTarget(pos), offset: offset)
            case .Press:
                break
            case .Release:
                instructionCreator.commit()
                state = .Idle
                pointSnapper.disable()
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle:
                pointSnapper.cycle()
                state = .Moving(handle: grabbedHandle, target: pointSnapper.getTarget(pos), offset: offset)
            case .Toggle:
                streightener.invert()
            }
        }
        
        if let entity = selection.selected {
            handleGrabber.enable(entity)
        } else {
            handleGrabber.disable()
        }
        
        publish()
    }
    
    private func publish() {
        if case .Moving(let grabbedHandle, let target, let offset) = state {
            let distance : protocol<RuntimeDistance, Labeled>
            switch target {
            case .Free(let position):
                distance = ConstantDistance(delta: streightener.adjust(position - grabbedHandle.position - offset, step: Angle(degree: 90)))
            case .Snap(let snap):
                distance = RelativeDistance(from: grabbedHandle.runtimePoint, to: snap.runtimePoint, direction: streightener.directionFor(snap.position - grabbedHandle.position))
            }
            
            instructionCreator.update(MorphInstruction(formId: grabbedHandle.formId, anchorId: grabbedHandle.anchorId, distance: distance))
        }
    }
}