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
    public typealias FactorType = protocol<RuntimeScaleFactor, Labeled>
    
    public var target : FormIdentifier? {
        return formId
    }
    
    public let formId : FormIdentifier
    public let factor : FactorType
    public let axis : RuntimeAxis
    public let fixPoint : PointType
    
    public init(formId: FormIdentifier, factor: FactorType, fixPoint: PointType, axis: RuntimeAxis = .None) {
        self.formId = formId
        self.factor = factor
        self.fixPoint = fixPoint
        self.axis = axis
    }
    
    public func evaluate<T:Runtime>(runtime: T) {
        guard let form = runtime.get(formId) as? Scalable else {
            runtime.reportError(.UnknownForm)
            return
        }
        guard let fix : Vec2d = fixPoint.getPositionFor(runtime) else {
            runtime.reportError(.InvalidFixPoint)
            return
        }
        guard let f : Double = factor.getFactorFor(runtime) else {
            runtime.reportError(.InvalidFactor)
            return
        }

        guard let a = axis.getVectorFor(runtime) else {
            runtime.reportError(.InvalidAxis)
            return
        }
        
        form.scaler.scale(runtime, factor: f, fix: fix, axis: a)
    }
    
    
    public func getDescription(stringifier: Stringifier) -> String {
        let formName = stringifier.labelFor(formId) ?? "???"
        let targetName : String
        switch axis {
        case .None:
            targetName = formName
        case .Named(let axisName, _, _):
            targetName = "\(formName)'s \(axisName)"
        }
        let factorLabel = factor.getDescription(stringifier)
        
        return  "Scale \(targetName) around \(fixPoint.getDescription(stringifier)) by \(factorLabel)"
    }
    
    public func analyze<T:Analyzer>(analyzer: T) {
    }
    
}