//
//  InstructionGroupBase.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

class InstructionGroupBase : InstructionGroup {
    var children : [Instruction]
    var target : FormIdentifier? {
        return nil
    }
    var parent : InstructionGroup? = nil
    
    init() {
        let null = NullInstruction()
        self.children = [null]
        null.parent = self
    }
    
    var count : Int { return children.count }
    
    subscript(index : Int) -> Instruction {
        get {
             return children[index]
        }
    }
    
    func indexOf(instruction : Instruction) -> Int? {
        return children.indexOf {
            $0 == instruction
        }
    }
    
    func insert(instruction : Instruction, relative : Instruction, pos: InstructionPosition) {
        if let index = indexOf(instruction) {
            let newIndex = index + pos.offset
            children.insert(instruction, atIndex: newIndex)
            instruction.parent = self
        }
    }
    
    func append(instruction : Instruction) {
        children.append(instruction)
    }
    
    func remove(instruction: Instruction) {
        if let index = indexOf(instruction) {
            children.removeAtIndex(index)
        }
    }
    
    func evaluate(runtime: Runtime) {
        runtime.scoped() {
            for instruction in self.children {
                if runtime.shouldStop { break }
                runtime.eval(instruction) {
                    instruction.evaluate(runtime)
                }
            }
        }
    }
    
    
    func analyze(analyzer: Analyzer) {
        for child in children {
            child.analyze(analyzer)
        }
    }
}