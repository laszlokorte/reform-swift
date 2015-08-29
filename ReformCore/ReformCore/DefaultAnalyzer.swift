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

class AnalyzerStringifier : Stringifier {
    private var forms = [FormIdentifier:Form]()
    private let expressionPrinter : ExpressionPrinter

    init(expressionPrinter : ExpressionPrinter) {
        self.expressionPrinter = expressionPrinter
    }

    func labelFor(formId: FormIdentifier) -> String? {
        return forms[formId].map{ $0.name }
    }

    func labelFor(formId: FormIdentifier, pointId: ExposedPointIdentifier) -> String? {
        return forms[formId].flatMap { $0.getPoints()[pointId].map { $0.getDescription(self) } }
    }

    func labelFor(formId: FormIdentifier, anchorId: AnchorIdentifier) -> String? {
        return forms[formId].flatMap{
            ($0 as? Morphable).flatMap {
                $0.getAnchors()[anchorId].map {
                    $0.name
                }
            }
        }
    }

    func stringFor(expression: Expression) -> String? {
        return expressionPrinter.toString(expression)
    }
}

final public class DefaultAnalyzer : Analyzer {
    public private(set) var instructions = [InstructionOutlineRow]()
    private let analyzerStringifier : AnalyzerStringifier
    public var stringifier : Stringifier {
        return analyzerStringifier
    }
    private var depth: Int = 0
    
    public init(expressionPrinter: ExpressionPrinter) {
        self.analyzerStringifier = AnalyzerStringifier(expressionPrinter: expressionPrinter)
    }
    
    public func analyze(block: () -> ()) {
        analyzerStringifier.forms.removeAll()
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
        analyzerStringifier.forms[form.identifier] = form
    }
    
    public func announceDepencency(id: PictureIdentifier) {
    
    }
}