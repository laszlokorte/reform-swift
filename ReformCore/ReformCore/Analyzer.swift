//
//  Analyzer.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public protocol Analyzer : class {
    func analyze(block: () -> ())
    
    func publish(instruction: Analyzable, label: String)
    
    func publish(instruction: Analyzable, label: String, block: () -> ())
    
    func announceForm(form: Form)
    
    func announceDepencency(id: PictureIdentifier)
    
    func get(id: FormIdentifier) -> Form?
    
    func getExpressionPrinter() -> ExpressionPrinter
}