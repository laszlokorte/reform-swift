//
//  RotateTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage


public class RotateTool : Tool {
    enum State
    {
        case Idle
        case Delegating
        case Rotating(handle: Handle, angle: Angle, offset: Vec2d)
    }
    
    var state : State = .Idle
    var snapType : PointType = []
    
    let stage : Stage
    let handleGrabber : HandleGrabber
    let streightener : Streightener
    let instructionCreator : InstructionCreator
    
    let selectionTool : SelectionTool
    let selection : FormSelection
    
    public init(stage: Stage, selection: FormSelection, handleGrabber: HandleGrabber, streightener: Streightener, instructionCreator: InstructionCreator, selectionTool: SelectionTool) {
        self.stage = stage
        self.selection = selection
        self.selectionTool = selectionTool
        
        
        self.handleGrabber = handleGrabber
        self.streightener = streightener
        self.instructionCreator = instructionCreator
    }
    
    public func setUp() {
        state = .Idle
        selectionTool.setUp()
    }
    
    public func tearDown() {
        state = .Idle
        handleGrabber.disable()
        selectionTool.tearDown()
    }
    
    public func refresh() {
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
        case .Rotating:
            instructionCreator.cancel()
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
                    
                    
                    instructionCreator
                        .beginCreation(RotateInstruction(formId: grabbedHandle.formId, angle: ConstantAngle(angle: Angle(degree: 0)), fixPoint: grabbedHandle.defaultPivot.0.runtimePoint))
                    
                    state = .Rotating(handle: grabbedHandle, angle: Angle(degree: 0), offset: pos - grabbedHandle.position)
                
                    
                } else {
                    state = .Delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .Cycle:
                handleGrabber.cycle()
            case .Toggle, .Release:
                break
            }
        case .Rotating(let grabbedHandle, _, let offset):
            switch input {
                
            case .ModifierChange:
                fallthrough
            case .Move:
                state = .Rotating(handle: grabbedHandle, angle: angle(pos - grabbedHandle.defaultPivot.0.position - offset) - angle(grabbedHandle.position - grabbedHandle.defaultPivot.0.position), offset: offset)
                
            case .Press:
                break
            case .Release:
                instructionCreator.commit()
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle:
                    break
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
        if case .Rotating(let grabbedHandle, let angle, _) = state {
            
            instructionCreator.update(RotateInstruction(formId: grabbedHandle.formId, angle: ConstantAngle(angle: streightener.adjust(angle)), fixPoint: grabbedHandle.defaultPivot.0.runtimePoint))
        }
    }
}