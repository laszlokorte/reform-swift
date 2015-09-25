//
//  FormInteratorInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


public struct FormIteratorInstruction : GroupInstruction {
    let proxyForm: ProxyForm
    public let formIds : [FormIdentifier]

    public var target : FormIdentifier? { return proxyForm.identifier }

    public init(proxyForm: ProxyForm, formIds : [FormIdentifier]) {
        self.proxyForm = proxyForm
        self.formIds = formIds
    }

    public func evaluate<T:Runtime where T.Ev==InstructionNode>(runtime: T, withChildren children: [InstructionNode]) {

        let forms = formIds.flatMap {
            runtime.get($0)
        }

        guard forms.count == formIds.count else {
            runtime.reportError(.UnknownForm)
            return
        }

        for form in forms {
            runtime.scoped() { runtime in
                runtime.declare(proxyForm)
                proxyForm.initWithRuntime(runtime, formId: form.identifier)
                for c in children where !runtime.shouldStop {
                    c.evaluate(runtime)
                }
            }
        }
    }

    public func getDescription(stringifier: Stringifier) -> String {
        let names = formIds.map({
            stringifier.labelFor($0) ?? "???"
        }).joinWithSeparator(", ")

        return "Foreach \(names) as \(proxyForm.name):"
    }

    public func analyze<T:Analyzer>(analyzer: T) {
    }

    public var isDegenerated : Bool {
        return false
    }
}