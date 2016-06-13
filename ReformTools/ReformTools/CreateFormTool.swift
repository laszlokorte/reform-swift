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

public final class CreateFormTool : Tool {
    
    enum State
    {
        case idle
        case started(startPoint: SnapPoint, form: protocol<ReformCore.Form, Creatable>, target: Target)
        case delegating
    }
    
    var state : State = .idle
    
    var snapType : PointType = [.Form, .Intersection]
    
    let formType : protocol<ReformCore.Form, Creatable>.Type
    
    let selection : FormSelection
    
    let selectionTool : SelectionTool

    let autoCenter : Bool
    let baseName : String
    let nameAllocator : NameAllocator
    let pointSnapper : PointSnapper
    let pointGrabber : PointGrabber
    let streightener : Streightener
    let aligner : Aligner
    let angleStep : Angle
    let ratio : (Int, Int)?
    let instructionCreator : InstructionCreator
    
    var idSequence : IdentifierSequence<FormIdentifier>
    
    public init(formType : protocol<ReformCore.Form, Creatable>.Type, idSequence : IdentifierSequence<FormIdentifier>, baseName: String, nameAllocator: NameAllocator, selection: FormSelection, pointSnapper: PointSnapper, pointGrabber: PointGrabber, streightener: Streightener, aligner: Aligner, instructionCreator: InstructionCreator, selectionTool: SelectionTool, autoCenter : Bool = false, angleStep: Angle = Angle(degree: 45), ratio : (Int, Int)? = nil) {
        self.formType = formType
        self.idSequence = idSequence
        self.baseName = baseName
        self.nameAllocator = nameAllocator
        self.selection = selection
        self.selectionTool = selectionTool
        
        self.pointSnapper = pointSnapper
        self.pointGrabber = pointGrabber
        
        self.streightener = streightener
        self.aligner = aligner
        
        self.instructionCreator = instructionCreator
        self.autoCenter = autoCenter
        self.angleStep = angleStep
        self.ratio = ratio
    }
    
    public func setUp() {
        selectionTool.setUp()
        state = .idle
        pointSnapper.enable(.any, pointType: snapType)
        pointGrabber.disable()
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
        selectionTool.focusChange()
    }
    
    public func cancel() {
        switch self.state {
        case .delegating, .idle:
            state = .idle
        case .started:
            instructionCreator.cancel()
            pointGrabber.disable()
                        
            state = .idle
        }
        
        selectionTool.cancel()
    }
    
    public func process(_ input: Input, atPosition pos: Vec2d, withModifier modifier: Modifier) {
        snapType = modifier.contains(.Glomp) ? (modifier.contains(.Free) ? [.Grid] : [.Glomp]) :
            modifier.contains(.Free) ? [.None] : [.Form, .Intersection]
        
        aligner.setMode(modifier.isAlignOption != self.autoCenter ? .centered : .aligned)
        if modifier.isStreight {
            streightener.enable()
        } else {
            streightener.disable()
        }
        
        switch state {
        case .delegating:
            selectionTool.process(input, atPosition: pos,  withModifier: modifier)
            switch input {
            case .modifierChange:
                pointSnapper.enable(.any, pointType: snapType)
            case .release:
                state = .idle
                process(.move, atPosition: pos, withModifier: modifier)
            case .cycle, .toggle, .move, .press:
                break
            }
        case .started(let startPoint, let form, _):
            switch input {
            case .modifierChange:
                if let formId = self.instructionCreator.target {
                    pointSnapper.enable(.except(.form(formId)), pointType: snapType)
                }
                fallthrough
            case .move:
                pointSnapper.searchAt(pos)
                
                if pointSnapper.current == nil {
                    streightener.reset()
                }
                
                state = .started(
                    startPoint: startPoint,
                    form: form,
                    target: pointSnapper.getTarget(pos)
                )
            case .release:
                instructionCreator.commit()
                state = .idle
                pointSnapper.enable(.any, pointType: snapType)
                process(.move, atPosition: pos, withModifier: modifier)
                pointGrabber.disable()
            case .cycle:
                pointSnapper.cycle()
                state = .started(
                startPoint: startPoint,
                form: form,
                target: pointSnapper.getTarget(pos)
                )
            case .toggle:
                streightener.invert()
            case .press:
                break
            }
        case .idle:
            switch input {
            case .modifierChange:
                pointSnapper.enable(.any, pointType: snapType)
                fallthrough
            case .move:
                pointSnapper.searchAt(pos)
            case .press:
                if let startPoint = pointSnapper.current {
                    let form = formType.init(id: idSequence.emitId(), name: self.nameAllocator.alloc(baseName, numbered: true))
                    let destination = RelativeDestination(from: startPoint.runtimePoint, to: startPoint.runtimePoint)
                    let instruction = CreateFormInstruction(form: form, destination: destination)
                    
                    self.instructionCreator.beginCreation(instruction)

                    if let formId = self.instructionCreator.target {
                        state = .started(
                            startPoint: startPoint,
                            form: form,
                            target: .snap(
                                point: startPoint)
                        )


                        selection.select(formId)
                        selectionTool.indend()
                        pointSnapper.enable(
                            .except(.form(formId)), pointType: snapType)
                        
                        pointGrabber.enable(formId)
                    }
                }  else {
                    state = .delegating
                    selectionTool.process(input, atPosition: pos, withModifier: modifier)
                }
            case .cycle:
                pointSnapper.cycle()
            case .toggle, .release:
                break
            }
        }
        
        publish()
    }
    
    func publish() {
        if case .started(let start, let form, let target) = state {
            let destination : protocol<RuntimeInitialDestination, Labeled>
            
            switch target {
            case .free(let targetPosition):
                let delta = streightener.adjust(targetPosition - start.position, step: self.angleStep)
                
                destination = FixSizeDestination(from: start.runtimePoint, delta: delta, alignment: aligner.getAlignment())
                
            case .snap(let snapPoint):
                destination = RelativeDestination(from: start.runtimePoint, to: snapPoint.runtimePoint, direction: streightener.directionFor(snapPoint.position - start.position, ratio: self.ratio), alignment: aligner.getAlignment())

            }
            
            instructionCreator
                .update(CreateFormInstruction(form: form, destination: destination))
        }
    }
    
}
