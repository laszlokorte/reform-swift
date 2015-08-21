//
//  DefaultAnalyzer.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

final public class DefaultAnalyzer : Analyzer {
    private var forms = [FormIdentifier:Form]()
    private let expressionPrinter : ExpressionPrinter
    
    public init(expressionPrinter: ExpressionPrinter) {
        self.expressionPrinter = expressionPrinter
    }
    
    public func analyze(block: () -> ()) {
        forms.removeAll()
        block()
    }
    
    public func publish(instruction: Analyzable, label: String) {
    }
    
    public func publish(instruction: Analyzable, label: String, block: () -> ()) {
    }
    
    public func announceForm(form: Form) {
        forms[form.identifier] = form
    }
    
    public func announceDepencency(id: PictureIdentifier) {
    
    }
    
    public func get(id: FormIdentifier) -> Form? {
        return forms[id]
    }
    
    public func getExpressionPrinter() -> ExpressionPrinter {
        return expressionPrinter
    }
}