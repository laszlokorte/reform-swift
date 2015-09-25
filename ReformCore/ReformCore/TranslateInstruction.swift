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
    
    public func evaluate<T:Runtime>(runtime: T) {
        guard let form = runtime.get(formId) as? Translatable else {
            runtime.reportError(.UnknownForm)
            return
        }
        guard let delta = distance.getDeltaFor(runtime) else {
            runtime.reportError(.InvalidDistance)
            return
        }
        
        form.translator.translate(runtime, delta: delta)
    }
    
    
    public func getDescription(stringifier: Stringifier) -> String {        let formName = stringifier.labelFor(formId) ?? "???"
        
        return "Move \(formName) \(distance.getDescription(stringifier))"
    }
    
    
    public func analyze<T:Analyzer>(analyzer: T) {
    }

    public var isDegenerated : Bool {
        return distance.isDegenerated
    }
}

extension TranslateInstruction : Mergeable {
    public func mergeWith(other: TranslateInstruction) -> TranslateInstruction? {
        guard formId == other.formId else {
            return nil
        }

        let newDistance : protocol<RuntimeDistance, Labeled>

        if let distanceA = distance as? ConstantDistance, distanceB = other.distance as? ConstantDistance {
            newDistance = combine(distance: distanceA, distance: distanceB)
        } else if let distanceA = distance as? RelativeDistance, distanceB = other.distance as? RelativeDistance where distanceB.direction is FreeDirection {
            newDistance = combine(distance: distanceA, distance: distanceB)
        } else if let distanceA = distance as? ConstantDistance, distanceB = other.distance as? RelativeDistance where distanceB.direction is FreeDirection {
            newDistance = combine(distance: distanceA, distance: distanceB)
        } else if let distanceA = distance as? RelativeDistance, distanceB = other.distance as? ConstantDistance where distanceB.isDegenerated {
            newDistance = distanceA
        } else {
            return nil
        }

        return TranslateInstruction(formId: formId, distance: newDistance)
    }
}