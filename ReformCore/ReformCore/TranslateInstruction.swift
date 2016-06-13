//
//  TranslateInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public struct TranslateInstruction : Instruction {
    public typealias DistanceType = protocol<RuntimeDistance, Labeled>
    
    public var target : FormIdentifier? {
        return formId
    }
    
    public let formId : FormIdentifier
    public let distance : DistanceType
    
    public init(formId: FormIdentifier, distance: DistanceType) {
        self.formId = formId
        self.distance = distance
    }
    
    public func evaluate<T:Runtime>(_ runtime: T) {
        guard let form = runtime.get(formId) as? Translatable else {
            runtime.reportError(.unknownForm)
            return
        }
        guard let delta = distance.getDeltaFor(runtime) else {
            runtime.reportError(.invalidDistance)
            return
        }
        
        form.translator.translate(runtime, delta: delta)
    }
    
    
    public func getDescription(_ stringifier: Stringifier) -> String {        let formName = stringifier.labelFor(formId) ?? "???"
        
        return "Move \(formName) \(distance.getDescription(stringifier))"
    }
    
    
    public func analyze<T:Analyzer>(_ analyzer: T) {
    }

    public var isDegenerated : Bool {
        return distance.isDegenerated
    }
}

extension TranslateInstruction : Mergeable {
    public func mergeWith(_ other: TranslateInstruction, force: Bool) -> TranslateInstruction? {
        guard formId == other.formId else {
            return nil
        }

        guard let newDistance = merge(distance: distance, distance: other.distance, force: force) else {
            return nil
        }

        return TranslateInstruction(formId: formId, distance: newDistance)
    }
}
