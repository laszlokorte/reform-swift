//
//  Procedure.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

private struct RootInstruction : GroupInstruction {
    var target : FormIdentifier? { return .None }
    
    func evaluate(runtime: Runtime, withChildren children: [InstructionNode]) {
        for child in children {
            child.evaluate(runtime)
        }
    }
    
    func getDescription(analyzer: Analyzer) -> String {
        return "Root"
    }
    
    func analyze(analyzer: Analyzer) {
    }
}

final public class Procedure {
    public let root = InstructionNode(group: RootInstruction())
    public let paper = Paper()
    
    public init() {
        
    }
    
    
}

extension Procedure {
    public func evaluateWith(runtime: Runtime) {
        runtime.run() { width, height in
            runtime.scoped() {
                runtime.declare(self.paper)
                self.paper.initWithRuntime(runtime, min: Vec2d(), max: Vec2d(x:Double(width), y: Double(height)))
                self.root.evaluate(runtime)
            }
        }
    }
}

extension Procedure {
    public func analyzeWith(analyzer: Analyzer) {
        analyzer.analyze() {
            analyzer.announceForm(self.paper)
            self.root.analyze(analyzer)
        }
    }
}