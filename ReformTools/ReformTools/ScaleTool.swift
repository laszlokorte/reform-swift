//
//  ScaleTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage


public final class ScaleTool : Tool {
    enum State
    {
        case idle
        case delegating
        case scaling(handle: AffineHandle, factor: Double, offset: Vec2d)
    }
    
    var state : State = .idle
    var snapType : PointType = []
    
    let stage : Stage
    let handleGrabber : AffineHandleGrabber
    let streightener : Streightener
    var pivot : PivotChoice = .primary
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
        state = .idle
        selectionTool.setUp()
        
        if let selected = selection.one {
            handleGrabber.enable(selected)
        }
    }
    
    public func tearDown() {
        instructionCreator.cancel()
        handleGrabber.disable()
        selectionTool.tearDown()
        state = .idle
    }
    
    public func refresh() {
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
            handleGrabber.disable()
            pivotUI.state = .hide
        case .scaling:
            instructionCreator.cancel()
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
        
        if modifier.isAlignOption {
            pivot = .secondary
        } else {
            pivot = .primary
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
                if let handle = handleGrabber.current {
                    pivotUI.state = .show(pivot.pointFor(handle))
                } else {
                    pivotUI.state = .hide
                }
            case .press:
                if let grabbedHandle = handleGrabber.current {
                    
                    instructionCreator
                        .beginCreation(ScaleInstruction(formId: grabbedHandle.formId.runtimeId, factor: ConstantScaleFactor(factor: 0), fixPoint: pivot.pointFor(grabbedHandle).runtimePoint, axis:  streightener.axisFor(grabbedHandle.scaleAxis.runtimeAxis)))
                    
                    state = .scaling(handle: grabbedHandle, factor: 1.0, offset: pos - grabbedHandle.position)
                    
                    
                } else {
                    state = .delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .cycle:
                handleGrabber.cycle()
            case .toggle, .release:
                break
            }
        case .scaling(let grabbedHandle, _, let offset):
            switch input {
                
            case .modifierChange:
                pivotUI.state = .show(pivot.pointFor(grabbedHandle))
                fallthrough
            case .move:
                let piv = pivot.pointFor(grabbedHandle)
                let axis = (grabbedHandle.position - piv.position)
                let distance = pos - piv.position - offset
                let length = axis.length²
                let factor = length == 0 ? 1 : dot(distance, axis)/axis.length²
                state = .scaling(handle: grabbedHandle, factor: factor, offset: offset)
            case .release:
                instructionCreator.commit()
                state = .idle
                process(.move, atPosition: pos, withModifier: modifier)
            case .cycle, .press:
                break
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
        if case .scaling(let grabbedHandle, let factor, _) = state {
            
            instructionCreator.update(ScaleInstruction(formId: grabbedHandle.formId.runtimeId, factor: ConstantScaleFactor(factor: factor), fixPoint: pivot.pointFor(grabbedHandle).runtimePoint, axis: streightener.axisFor(grabbedHandle.scaleAxis.runtimeAxis)))
        }
    }
}
