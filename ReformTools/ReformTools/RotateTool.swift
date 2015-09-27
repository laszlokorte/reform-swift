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


public final class RotateTool : Tool {
    enum State
    {
        case Idle
        case Delegating
        case Rotating(handle: AffineHandle, angle: Angle, offset: Vec2d)
    }
    
    var pivot : PivotChoice = .Primary
    var state : State = .Idle
    var snapType : PointType = []
    
    let stage : Stage
    let handleGrabber : AffineHandleGrabber
    let streightener : Streightener
    let instructionCreator : InstructionCreator
    
    let selectionTool : SelectionTool
    let selection : FormSelection
    
    let pivotUI : PivotUI
    
    public init(stage: Stage, selection: FormSelection, handleGrabber: AffineHandleGrabber, streightener: Streightener, instructionCreator: InstructionCreator, selectionTool: SelectionTool, pivotUI : PivotUI) {
        self.stage = stage
        self.selection = selection
        self.selectionTool = selectionTool
        self.pivotUI = pivotUI
        
        self.handleGrabber = handleGrabber
        self.streightener = streightener
        self.instructionCreator = instructionCreator
    }
    
    public func setUp() {
        state = .Idle
        selectionTool.setUp()
        if let selected = selection.one {
            handleGrabber.enable(selected)
        }
    }
    
    public func tearDown() {
        instructionCreator.cancel()
        handleGrabber.disable()
        selectionTool.tearDown()
        state = .Idle
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
            handleGrabber.disable()
            pivotUI.state = .Hide
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
        
        
        if modifier.isAlignOption {
            pivot = .Secondary
        } else {
            pivot = .Primary
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
                if let handle = handleGrabber.current {
                    pivotUI.state = .Show(pivot.pointFor(handle))
                } else {
                    pivotUI.state = .Hide
                }
            case .Press:
                if let grabbedHandle = handleGrabber.current {
                    
                    
                    instructionCreator
                        .beginCreation(RotateInstruction(formId: grabbedHandle.formId.runtimeId, angle: ConstantAngle(angle: Angle(degree: 0)), fixPoint: pivot.pointFor(grabbedHandle).runtimePoint))
                    
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
                pivotUI.state = .Show(pivot.pointFor(grabbedHandle))
                fallthrough
            case .Move:
                let piv = pivot.pointFor(grabbedHandle)
                state = .Rotating(handle: grabbedHandle, angle:
                    angleBetween(vector: pos - piv.position - offset,
                        vector: grabbedHandle.position - piv.position), offset: offset)
            case .Release:
                instructionCreator.commit()
                state = .Idle
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle, .Press:
                    break
            case .Toggle:
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
        if case .Rotating(let grabbedHandle, let angle, _) = state {
            
            instructionCreator.update(RotateInstruction(formId: grabbedHandle.formId.runtimeId, angle: ConstantAngle(angle: streightener.adjust(angle)), fixPoint: pivot.pointFor(grabbedHandle).runtimePoint))
        }
    }
}