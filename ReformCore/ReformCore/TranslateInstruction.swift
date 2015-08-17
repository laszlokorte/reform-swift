//
//  TranslateInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


final public class TranslateInstruction : Instruction {
    public typealias DistanceType = protocol<RuntimeDistance, Labeled>
    
    public var parent : InstructionGroup?
    
    public var target : FormIdentifier? {
        return formId
    }
    
    let formId : FormIdentifier
    let distance : DistanceType
    
    public init(formId: FormIdentifier, distance: DistanceType) {
        self.formId = formId
        self.distance = distance
    }
    
    public func evaluate(runtime: Runtime) {
        guard let form = runtime.get(formId) as? Translatable else {
            runtime.reportError(self, error: .UnknownForm)
            return
        }
        guard let delta = distance.getDeltaFor(runtime) else {
            runtime.reportError(self, error: .InvalidDistance)
            return
        }
        
        form.translator.translate(runtime, delta: delta)
    }
    
    
    public func analyze(analyzer: Analyzer) {
        let formName = analyzer.get(formId)?.name ?? "???"
        
        analyzer.publish(self, label: "Move \(formName) \(distance.getDescription(analyzer))")
    }
    
}