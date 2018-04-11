//
//  ScaleInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath

public struct ScaleInstruction : Instruction {
    public typealias PointType = LabeledPoint
    public typealias FactorType = RuntimeScaleFactor & Labeled
    
    public var target : FormIdentifier? {
        return formId
    }
    
    public let formId : FormIdentifier
    public let factor : FactorType
    public let axis : RuntimeAxis
    public let fixPoint : PointType
    
    public init(formId: FormIdentifier, factor: FactorType, fixPoint: PointType, axis: RuntimeAxis = .none) {
        self.formId = formId
        self.factor = factor
        self.fixPoint = fixPoint
        self.axis = axis
    }
    
    public func evaluate<T:Runtime>(_ runtime: T) {
        guard let form = runtime.get(formId) as? Scalable else {
            runtime.reportError(.unknownForm)
            return
        }
        guard let fix : Vec2d = fixPoint.getPositionFor(runtime) else {
            runtime.reportError(.invalidFixPoint)
            return
        }
        guard let f : Double = factor.getFactorFor(runtime) else {
            runtime.reportError(.invalidFactor)
            return
        }

        guard let a = axis.getVectorFor(runtime) else {
            runtime.reportError(.invalidAxis)
            return
        }
        
        form.scaler.scale(runtime, factor: f, fix: fix, axis: a)
    }
    
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        let formName = stringifier.labelFor(formId) ?? "???"
        let targetName : String
        switch axis {
        case .none:
            targetName = formName
        case .named(let axisName, _, _):
            targetName = "\(formName)'s \(axisName)"
        }
        let factorLabel = factor.getDescription(stringifier)
        
        return  "Scale \(targetName) around \(fixPoint.getDescription(stringifier)) by \(factorLabel)"
    }
    
    public func analyze<T:Analyzer>(_ analyzer: T) {
    }

    public var isDegenerated : Bool {
        return factor.isDegenerated
    }
    
}

extension ScaleInstruction : Mergeable {
    public func mergeWith(_ other: ScaleInstruction, force: Bool) -> ScaleInstruction? {
        guard formId == other.formId else {
            return nil
        }

        if force {
            return other
        }
        
        guard axis == other.axis else {
            return nil
        }
        guard fixPoint.isEqualTo(other.fixPoint) else {
            return nil
        }

        guard let factorA = factor as? ConstantScaleFactor, let factorB = other.factor as? ConstantScaleFactor else {
            return nil
        }

        return ScaleInstruction(formId: formId, factor: combine(factor: factorA, factor: factorB), fixPoint: fixPoint, axis: axis)
    }
}
