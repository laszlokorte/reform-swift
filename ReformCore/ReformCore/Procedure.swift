//
//  Procedure.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

private struct RootInstruction : GroupInstruction {
    var target : FormIdentifier? { return .none }
    
    func evaluate<T:Runtime where T.Ev==InstructionNode>(_ runtime: T, withChildren children: [InstructionNode]) {
        for child in children {
            child.evaluate(runtime)
        }
    }
    
    func getDescription(_ stringifier: Stringifier) -> String {
        return "Root"
    }
    
    func analyze<T:Analyzer>(_ analyzer: T) {
    }

    var isDegenerated : Bool {
        return false
    }
}

final public class Procedure {
    public let root : InstructionNode
    public let paper = Paper()
    
    public init() {
        root = InstructionNode(group: RootInstruction())
    }

    public init(children: [InstructionNode]) {
        root = InstructionNode(group: RootInstruction(), children: children)
    }
}

extension Procedure {
    public func evaluateWith<T:Runtime where T.Ev==InstructionNode>(width: Double, height: Double, runtime: T) {
        runtime.run(width: width, height: height) { [] r in
            r.scoped() { r in
                r.declare(self.paper)
                self.paper.initWithRuntime(runtime, min: Vec2d(), max: Vec2d(x:Double(width), y: Double(height)))
                self.root.evaluate(runtime)
            }
        }
    }
}

extension Procedure {
    public func analyzeWith<T:Analyzer>(_ analyzer: T) {
        analyzer.analyze() {
            analyzer.announceForm(self.paper)
            self.root.analyze(analyzer)
        }
    }
}
