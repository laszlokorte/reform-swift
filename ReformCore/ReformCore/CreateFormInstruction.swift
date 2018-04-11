//
//  CreateFormInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct CreateFormInstruction : Instruction {
    public typealias DestinationType = RuntimeInitialDestination & Labeled
    
    public var target : FormIdentifier? {
        return form.identifier
    }
    
    public let form : Form & Creatable
    public let destination : DestinationType
    
    public init(form : Form & Creatable, destination: DestinationType) {
        self.form = form
        self.destination = destination
    }
    
    public func evaluate<T:Runtime>(_ runtime: T) {
        guard let (min, max) = destination.getMinMaxFor(runtime) else {
            runtime.reportError(.invalidDestination)
            return
        }
        runtime.declare(form)
        form.initWithRuntime(runtime, min: min, max: max)
    }
    
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        return "Create \(form.name) \(destination.getDescription(stringifier))"
    }
    
    public func analyze<T:Analyzer>(_ analyzer: T) {
        analyzer.announceForm(form)
        
        if let picture = form as? PictureForm,
                let id = picture.pictureIdentifier {
            analyzer.announceDepencency(id)
        }
    }

    public var isDegenerated : Bool {
        return destination.isDegenerated
    }
}

extension CreateFormInstruction : Mergeable {
    public func mergeWith(_ other: CreateFormInstruction, force: Bool) -> CreateFormInstruction? {

        guard type(of: other.form) == type(of: form) else {
            return nil
        }

        if force {
            return CreateFormInstruction(form: form, destination: other.destination)
        }

        return nil
    }
}
