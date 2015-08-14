//
//  ForLoopInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

class ForLoopInstruction : InstructionGroupBase {
    var expression : Expression
    
    init(expression : Expression) {
        self.expression = expression
    }
    
    override func evaluate(runtime: Runtime) {
        guard case .Success(.IntValue(let count)) = expression.eval(runtime.getDataSet()) else {
            runtime.reportError(self, error: .InvalidExpression)
            return
        }
        
        for var i=0; i<count;i++ {
            super.evaluate(runtime)
        }
    }
    
    override func analyze(analyzer: Analyzer) {
        let expressionString = analyzer.getExpressionPrinter().toString(expression) ?? "???"
        
        analyzer.publish(self, label: "Repeat \(expressionString) times:") {
            super.analyze(analyzer)
        }
    }
}