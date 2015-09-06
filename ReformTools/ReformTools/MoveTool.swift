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

public final class MoveTool : Tool {

    enum State
    {
        case Idle
        case Delegating
        case Moving(point: EntityPoint, target: Target, offset: Vec2d)
    }
    
    var state : State = .Idle
    var snapType : PointType = []
    
    let stage : Stage
    let pointGrabber : PointGrabber
    let pointSnapper : PointSnapper
    let streightener : Streightener
    let instructionCreator : InstructionCreator
    
    let selectionTool : SelectionTool
    let selection : FormSelection
    
    public init(stage: Stage, selection: FormSelection, pointSnapper: PointSnapper, pointGrabber: PointGrabber, streightener: Streightener, instructionCreator: InstructionCreator, selectionTool: SelectionTool) {
        self.stage = stage
        self.selection = selection
        self.selectionTool = selectionTool
        
        
        self.pointSnapper = pointSnapper
        self.pointGrabber = pointGrabber
        self.streightener = streightener
        self.instructionCreator = instructionCreator
    }
    
    public func setUp() {
        state = .Idle
        selectionTool.setUp()
        
        if let selected = selection.one {
            pointGrabber.enable(selected)
        }
    }
    
    public func tearDown() {
        instructionCreator.cancel()
        pointSnapper.disable()
        pointGrabber.disable()
        selectionTool.tearDown()
        state = .Idle

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
                pointGrabber.searchAt(pos)
            case .Press:
                if let grabbedPoint = pointGrabber.current {
 
                    let distance = ConstantDistance(delta: Vec2d())
                    let instruction = TranslateInstruction(formId: grabbedPoint.formId, distance: distance)
                    
                    instructionCreator
                        .beginCreation(instruction)
                    
                    state = .Moving(point: grabbedPoint, target: .Free(position: pos), offset: pos - grabbedPoint.position)
                        
                    pointSnapper.enable(.Except(grabbedPoint.formId), pointType: snapType)
                    
                } else {
                    state = .Delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .Cycle:
                pointGrabber.cycle()
            case .Toggle, .Release:
                break
            }
        case .Moving(let grabPoint, _, let offset):
            switch input {
                
            case .ModifierChange:
                pointSnapper.enable(.Except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .Move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .Moving(point: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .Press:
                break
            case .Release:
                instructionCreator.commit()
                state = .Idle
                pointSnapper.disable()
                process(.Move, atPosition: pos, withModifier: modifier)
            case .Cycle:
                pointSnapper.cycle()
                state = .Moving(point: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .Toggle:
                streightener.invert()
            }
        }
        
        if let entity = selection.one {
            pointGrabber.enable(entity)
        } else {
            pointGrabber.disable()
        }
        
        publish()
    }
    
    private func publish() {
        if case .Moving(let activePoint, let target, let offset) = state {
            let distance : protocol<RuntimeDistance, Labeled>
            switch target {
            case .Free(let position):
                distance = ConstantDistance(delta: streightener.adjust(position - activePoint.position - offset,step: Angle(degree: 45)))
            case .Snap(let snap):
                distance = RelativeDistance(from: activePoint.runtimePoint, to: snap.runtimePoint, direction: streightener.directionFor(snap.position - activePoint.position))
            }
            
            instructionCreator.update(TranslateInstruction(formId: activePoint.formId, distance: distance))
        }
    }
    
}