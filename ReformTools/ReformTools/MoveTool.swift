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
        case idle
        case delegating
        case moving(point: EntityPoint, target: Target, offset: Vec2d)
    }
    
    var state : State = .idle
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
        state = .idle
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
        state = .idle

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
        snapType = modifier.contains(.Glomp) ? (modifier.contains(.Free) ? [.Grid] : [.Glomp]) : modifier.contains(.Free) ? [.None] : [.Form, .Intersection]
        
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
                pointGrabber.searchAt(pos)
            case .press:
                if let grabbedPoint = pointGrabber.current {
 
                    let distance = ConstantDistance(delta: Vec2d())
                    let instruction = TranslateInstruction(formId: grabbedPoint.formId.runtimeId, distance: distance)
                    
                    instructionCreator
                        .beginCreation(instruction)
                    
                    state = .moving(point: grabbedPoint, target: .free(position: pos), offset: pos - grabbedPoint.position)
                        
                    pointSnapper.enable(.except(grabbedPoint.formId), pointType: snapType)
                    
                } else {
                    state = .delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .cycle:
                pointGrabber.cycle()
            case .toggle, .release:
                break
            }
        case .moving(let grabPoint, _, let offset):
            switch input {
                
            case .modifierChange:
                pointSnapper.enable(.except(grabPoint.formId), pointType: snapType)
                fallthrough
            case .move:
                pointSnapper.searchAt(pos)
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .moving(point: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .press:
                break
            case .release:
                instructionCreator.commit()
                state = .idle
                pointSnapper.disable()
                process(.move, atPosition: pos, withModifier: modifier)
            case .cycle:
                pointSnapper.cycle()
                state = .moving(point: grabPoint, target: pointSnapper.getTarget(pos), offset: offset)
            case .toggle:
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
        if case .moving(let activePoint, let target, let offset) = state {
            let distance : RuntimeDistance & Labeled
            switch target {
            case .free(let position):
                distance = ConstantDistance(delta: streightener.adjust(position - activePoint.position - offset,step: Angle(degree: 45)))
            case .snap(let snap):
                distance = RelativeDistance(from: activePoint.runtimePoint, to: snap.runtimePoint, direction: streightener.directionFor(snap.position - activePoint.position))
            }
            
            instructionCreator.update(TranslateInstruction(formId: activePoint.formId.runtimeId, distance: distance))
        }
    }
    
}
