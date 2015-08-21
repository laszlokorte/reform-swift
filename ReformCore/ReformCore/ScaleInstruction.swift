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
    
    let formId : FormIdentifier
    let factor : FactorType
    let axis : RuntimeAxis
    var fixPoint : PointType
    
    public init(formId: FormIdentifier, factor: FactorType, fixPoint: PointType, axis: RuntimeAxis = .None) {
        self.formId = formId
        self.factor = factor
        self.fixPoint = fixPoint
        self.axis = axis
    }
    
    public func evaluate(runtime: Runtime) {
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
    
    
    public func getDescription(analyzer: Analyzer) -> String {
        let formName = analyzer.get(formId)?.name ?? "???"
        let targetName : String
        switch axis {
        case .None:
            targetName = formName
        case .Named(let axisName):
            targetName = "\(formName)'s \(axisName)"
        }
        
        return  "Scale \(targetName) around \(fixPoint.getDescription(analyzer)) by \(factor)"
    }
    
    public func analyze(analyzer: Analyzer) {
    }
    
}