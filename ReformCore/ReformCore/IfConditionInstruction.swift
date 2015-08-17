//
//  IfConditionInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public struct IfConditionInstruction : GroupInstruction {
    var expression : Expression
    
    public var target : FormIdentifier? { return nil }

    init(expression : Expression) {
        self.expression = expression
    }
    
    public func evaluate(runtime: Runtime, withChildren children: [InstructionNode]) {
        guard case .Success(.BoolValue(let bool)) = expression.eval(runtime.getDataSet()) else {
            runtime.reportError(.InvalidExpression)
            return
        }
        
        if bool {
            for c in children {
                c.evaluate(runtime)
            }
        }
    }
    
    
    public func getDescription(analyzer: Analyzer) -> String {        let expressionString = analyzer.getExpressionPrinter().toString(expression) ?? "???"
        
        return "if \(expressionString):"
    }

    public func analyze(analyzer: Analyzer) {
    }
}