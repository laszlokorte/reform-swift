//
//  Procedure.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public class Procedure {
    public let root : InstructionGroup = InstructionGroupBase()
    public let paper = Paper()
    
    public init() {
        
    }
    
    public func addInstruction(instruction : Instruction, position : InstructionPosition, base : Instruction)
    {
        guard let parent = base.parent else {
            return
        }
        
        if base is InstructionGroup {
            guard let index = parent.indexOf(base) where index < parent.count && parent[index+1] is NullInstruction else {
                return
            }
            
            addInstruction(instruction, position: position, base: parent[index+1])
            
            return
        }
    
        parent.insert(instruction, relative: base, pos: position)
        
        if instruction is InstructionGroup {
            addInstruction(NullInstruction(), position: InstructionPosition.After, base: instruction)
        }
    }
    
    public func removeInstruction(instruction : Instruction)
    {
        guard let parent = instruction.parent else {
            return
        }
    
        if instruction is InstructionGroup, let index = parent.indexOf(instruction) where index < parent.count && parent[index+1] is NullInstruction {
            removeInstruction(parent[index+1])
        }
        
        parent.remove(instruction)
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