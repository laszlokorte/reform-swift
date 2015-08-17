//
//  ForLoopInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public struct ForLoopInstruction : GroupInstruction {
    var expression : Expression
    
    public var target : FormIdentifier? { return nil }
    
    init(expression : Expression) {
        self.expression = expression
    }
    
    public func evaluate(runtime: Runtime, withChildren children: [InstructionNode]) {
        guard case .Success(.IntValue(let count)) = expression.eval(runtime.getDataSet()) else {
            runtime.reportError(.InvalidExpression)
            return
        }
        
        for var i=0; i<count;i++ {
            for c in children {
                c.evaluate(runtime)
            }
        }
    }
    
    public func getDescription(analyzer: Analyzer) -> String {
        let expressionString = analyzer.getExpressionPrinter().toString(expression) ?? "???"
        
        return "Repeat \(expressionString) times:"
    }
    
    public func analyze(analyzer: Analyzer) {
    }
}