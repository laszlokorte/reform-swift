//
//  RotateInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct RotateInstruction : Instruction {
    public typealias PointType = LabeledPoint
    public typealias AngleType = protocol<RuntimeRotationAngle, Labeled>
    
    public var target : FormIdentifier? {
        return formId
    }
    
    public let formId : FormIdentifier
    public let angle : AngleType
    public let fixPoint : PointType
    
    public init(formId: FormIdentifier, angle: AngleType, fixPoint: PointType) {
        self.formId = formId
        self.angle = angle
        self.fixPoint = fixPoint
    }
    
    public func evaluate<T:Runtime>(_ runtime: T) {
        guard let form = runtime.get(formId) as? Rotatable else {
            runtime.reportError(.unknownForm)
            return
        }
        guard let fix : Vec2d = fixPoint.getPositionFor(runtime) else {
            runtime.reportError(.invalidFixPoint)
            return
        }
        guard let a : Angle = angle.getAngleFor(runtime) else {
            runtime.reportError(.invalidAngle)
            return
        }
        
        form.rotator.rotate(runtime, angle: a, fix: fix)
    }
    
    
    public func getDescription(_ stringifier: Stringifier) -> String {        let formName = stringifier.labelFor(formId) ?? "???"
        
        return "Rotate \(formName) around \(fixPoint.getDescription(stringifier)) by \(angle.getDescription(stringifier))"
    }
    
    
    
    public func analyze<T:Analyzer>(_ analyzer: T) {
    }


    public var isDegenerated : Bool {
        return angle.isDegenerated
    }
}

extension RotateInstruction : Mergeable {
    public func mergeWith(_ other: RotateInstruction, force: Bool) -> RotateInstruction? {
        guard formId == other.formId else {
            return nil
        }

        if force {
            return other
        }

        guard fixPoint.isEqualTo(other.fixPoint) else {
            return nil
        }

        guard let angleA = angle as? ConstantAngle, angleB = other.angle as? ConstantAngle else {
            return nil
        }

        return RotateInstruction(formId: formId, angle: combine(angle: angleA, angle: angleB), fixPoint: fixPoint)
    }
}
