//
//  IfConditionInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

final public class IfConditionInstruction : InstructionGroupBase {
    var expression : Expression

    init(expression : Expression) {
        self.expression = expression
    }
    
    override public func evaluate(runtime: Runtime) {
        guard case .Success(.BoolValue(let bool)) = expression.eval(runtime.getDataSet()) else {
            runtime.reportError(self, error: .InvalidExpression)
            return
        }
        
        if bool {
            super.evaluate(runtime)
        }
    }
    
    
    override public func analyze(analyzer: Analyzer) {
        let expressionString = analyzer.getExpressionPrinter().toString(expression) ?? "???"
        
        analyzer.publish(self, label: "if \(expressionString):") {
            super.analyze(analyzer)
        }
    }

}