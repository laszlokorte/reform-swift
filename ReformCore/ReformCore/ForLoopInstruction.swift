//
//  ForLoopInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformExpression

public struct ForLoopInstruction : GroupInstruction {
    public let expression : ReformExpression.Expression
    
    public var target : FormIdentifier? { return nil }
    
    public init(expression : ReformExpression.Expression) {
        self.expression = expression
    }
    
    public func evaluate<T:Runtime>(_ runtime: T, withChildren children: [InstructionNode]) where T.Ev==InstructionNode {
        guard case .success(.intValue(let count)) = expression.eval(runtime.getDataSet()) else {
            runtime.reportError(.invalidExpression)
            return
        }
        
        for _ in 0..<count {
            runtime.scoped() { runtime in
                for c in children where !runtime.shouldStop {
                    c.evaluate(runtime)
                }
            }
        }
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        let expressionString = stringifier.stringFor(expression) ?? "???"
        
        return "Repeat \(expressionString) times:"
    }
    
    public func analyze<T:Analyzer>(_ analyzer: T) {
    }

    public var isDegenerated : Bool {
        return false
    }
}
