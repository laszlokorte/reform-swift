//
//  MorphInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

class MorphInstruction : Instruction {
    typealias DistanceType = protocol<RuntimeDistance, Labeled>
    
    var parent : InstructionGroup?
    
    var target : FormIdentifier? {
        return formId
    }
    
    let formId : FormIdentifier
    let anchorId : AnchorIdentifier
    var distance : DistanceType
    
    init(formId : FormIdentifier, anchorId: AnchorIdentifier, distance : DistanceType) {
        self.formId = formId
        self.anchorId = anchorId
        self.distance = distance
    }
    
    func evaluate(runtime: Runtime) {
        guard let form = runtime.get(formId) as? Morphable else {
            runtime.reportError(self, error: .UnknownForm)
            return
        }
        guard let anchor = form.getAnchors()[anchorId] else {
            runtime.reportError(self, error: .UnknownAnchor)
            return
        }
        guard let delta = distance.getDeltaFor(runtime) else {
            runtime.reportError(self, error: .InvalidDistance)
            return
        }
        
        anchor.translate(runtime, delta: delta)
    }
    
    
    func analyze(analyzer: Analyzer) {
        let form = analyzer.get(formId)
        let formName = form?.name ?? "???"
        let anchorName = (form as? Morphable)?.getAnchors()[anchorId]?.name ?? "??"
        
        analyzer.publish(self, label: "Move \(formName)'s \(anchorName) \(distance.getDescription(analyzer))")
    }
    
}