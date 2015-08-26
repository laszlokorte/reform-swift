//
//  DefaultAnalyzer.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public struct InstructionOutlineRow {
    public let node : InstructionNode
    public let label : String
    public let depth : Int
    public let isGroup : Bool
}

final public class DefaultAnalyzer : Analyzer {
    private var forms = [FormIdentifier:Form]()
    public private(set) var instructions = [InstructionOutlineRow]()
    private let expressionPrinter : ExpressionPrinter
    private var depth: Int = 0
    
    public init(expressionPrinter: ExpressionPrinter) {
        self.expressionPrinter = expressionPrinter
    }
    
    public func analyze(block: () -> ()) {
        forms.removeAll()
        instructions.removeAll()
        depth = 0
        block()
    }
    
    public func publish(instruction: Analyzable, label: String) {
        guard let node = instruction as? InstructionNode else {
            return
        }
        instructions.append(InstructionOutlineRow(node: node, label: label, depth: depth, isGroup: false))
    }
    
    public func publish(instruction: Analyzable, label: String, block: () -> ()) {
        guard let node = instruction as? InstructionNode else {
            return
        }

        // skip root
        if depth > 0 {
            instructions.append(InstructionOutlineRow(node: node, label: label, depth: depth, isGroup: true))
        }

        depth++
        defer { depth-- }

        block()
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