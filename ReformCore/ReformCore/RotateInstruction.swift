//
//  RotateInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

class RotateInstruction : Instruction {
    typealias PointType = LabeledPoint
    typealias AngleType = protocol<RuntimeRotationAngle, Labeled>
    
    
    var parent : InstructionGroup?
    
    var target : FormIdentifier? {
        return formId
    }
    
    let formId : FormIdentifier
    let angle : AngleType
    var fixPoint : PointType
    
    init(formId: FormIdentifier, angle: AngleType, fixPoint: PointType) {
        self.formId = formId
        self.angle = angle
        self.fixPoint = fixPoint
    }
    
    func evaluate(runtime: Runtime) {
        guard let form = runtime.get(formId) as? Rotatable else {
            runtime.reportError(self, error: .UnknownForm)
            return
        }
        guard let fix : Vec2d = fixPoint.getPositionFor(runtime) else {
            runtime.reportError(self, error: .InvalidFixPoint)
            return
        }
        guard let a : Angle = angle.getAngleFor(runtime) else {
            runtime.reportError(self, error: .InvalidAngle)
            return
        }
        
        form.rotator.rotate(runtime, angle: a, fix: fix)
    }
    
    
    func analyze(analyzer: Analyzer) {
        let formName = analyzer.get(formId)?.name ?? "???"
        
        analyzer.publish(self, label: "Rotate \(formName) around \(fixPoint.getDescription(analyzer)) by \(angle.getDescription(analyzer))")
    }
    
}