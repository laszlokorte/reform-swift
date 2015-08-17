//
//  CreateFormInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class CreateFormInstruction : Instruction {
    public typealias DestinationType = protocol<RuntimeInitialDestination, Labeled>
    
    public var parent : InstructionGroup?
    
    public var target : FormIdentifier? {
        return form.identifier
    }
    
    let form : Form
    var destination : DestinationType
    
    public init(form : Form, destination: DestinationType) {
        self.form = form
        self.destination = destination
    }
    
    public func evaluate(runtime: Runtime) {
        guard let (min, max) = destination.getMinMaxFor(runtime) else {
            runtime.reportError(self, error: .InvalidDestination)
            return
        }
        runtime.declare(form)
        form.initWithRuntime(runtime, min: min, max: max)
    }
    
    
    public func analyze(analyzer: Analyzer) {
        analyzer.announceForm(form)
        analyzer.publish(self, label: "Create \(form.name) \(destination.getDescription(analyzer))")
        if let picture = form as? PictureForm, let id = picture.pictureIdentifier {
            analyzer.announceDepencency(id)
        }
    }
    
}