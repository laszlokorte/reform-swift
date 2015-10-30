//
//  MorphInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct MorphInstruction : Instruction {
    public typealias DistanceType = protocol<RuntimeDistance, Labeled>
    
    public var target : FormIdentifier? {
        return formId
    }
    
    public let formId : FormIdentifier
    public let anchorId : AnchorIdentifier
    public let distance : DistanceType
    
    public init(formId : FormIdentifier, anchorId: AnchorIdentifier, distance : DistanceType) {
        self.formId = formId
        self.anchorId = anchorId
        self.distance = distance
    }
    
    public func evaluate<T:Runtime>(runtime: T) {
        guard let form = runtime.get(formId) as? Morphable else {
            runtime.reportError(.UnknownForm)
            return
        }
        guard let anchor = form.getAnchors()[anchorId] else {
            runtime.reportError(.UnknownAnchor)
            return
        }
        guard let delta = distance.getDeltaFor(runtime) else {
            runtime.reportError(.InvalidDistance)
            return
        }
        
        anchor.translate(runtime, delta: delta)
    }
    
    
    public func getDescription(stringifier: Stringifier) -> String {
        let formName = stringifier.labelFor(formId) ?? "???"
        let anchorName = stringifier.labelFor(formId, anchorId: anchorId) ?? "??"
        
        return "Move \(formName)'s \(anchorName) \(distance.getDescription(stringifier))"
    }
    
    public func analyze<T:Analyzer>(analyzer: T) {
    }

    public var isDegenerated : Bool {
        return distance.isDegenerated
    }
}

extension MorphInstruction : Mergeable {
    public func mergeWith(other: MorphInstruction, force: Bool) -> MorphInstruction? {
        guard formId == other.formId else {
            return nil
        }
        guard anchorId == other.anchorId else {
            return nil
        }

        guard let newDistance = merge(distance: distance, distance: other.distance, force: force) else {
            return nil
        }

        return MorphInstruction(formId: formId, anchorId: anchorId, distance: newDistance)
    }
}