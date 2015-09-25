//
//  CreateFormInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct CreateFormInstruction : Instruction {
    public typealias DestinationType = protocol<RuntimeInitialDestination, Labeled>
    
    public var target : FormIdentifier? {
        return form.identifier
    }
    
    public let form : protocol<Form, Creatable>
    public let destination : DestinationType
    
    public init(form : protocol<Form, Creatable>, destination: DestinationType) {
        self.form = form
        self.destination = destination
    }
    
    public func evaluate<T:Runtime>(runtime: T) {
        guard let (min, max) = destination.getMinMaxFor(runtime) else {
            runtime.reportError(.InvalidDestination)
            return
        }
        runtime.declare(form)
        form.initWithRuntime(runtime, min: min, max: max)
    }
    
    
    public func getDescription(stringifier: Stringifier) -> String {
        return "Create \(form.name) \(destination.getDescription(stringifier))"
    }
    
    public func analyze<T:Analyzer>(analyzer: T) {
        analyzer.announceForm(form)
        
        if let picture = form as? PictureForm,
                id = picture.pictureIdentifier {
            analyzer.announceDepencency(id)
        }
    }

    public var isDegenerated : Bool {
        return destination.isDegenerated
    }
}

extension CreateFormInstruction : Mergeable {
    public func mergeWith(other: CreateFormInstruction) -> CreateFormInstruction? {
        return nil
    }
}