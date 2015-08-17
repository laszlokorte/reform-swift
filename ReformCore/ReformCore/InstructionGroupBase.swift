//
//  InstructionGroupBase.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public class InstructionGroupBase : InstructionGroup {
    var children : [Instruction]
    public var target : FormIdentifier? {
        return nil
    }
    public var parent : InstructionGroup? = nil
    
    init() {
        let null = NullInstruction()
        self.children = [null]
        null.parent = self
    }
    
    public var count : Int { return children.count }
    
    public subscript(index : Int) -> Instruction {
        get {
             return children[index]
        }
    }
    
    public func indexOf(instruction : Instruction) -> Int? {
        return children.indexOf {
            $0 == instruction
        }
    }
    
    public func insert(instruction : Instruction, relative : Instruction, pos: InstructionPosition) {
        if let index = indexOf(instruction) {
            let newIndex = index + pos.offset
            children.insert(instruction, atIndex: newIndex)
            instruction.parent = self
        }
    }
    
    public func append(instruction : Instruction) {
        children.append(instruction)
    }
    
    public func remove(instruction: Instruction) {
        if let index = indexOf(instruction) {
            children.removeAtIndex(index)
        }
    }
    
    public func evaluate(runtime: Runtime) {
        runtime.scoped() {
            for instruction in self.children {
                if runtime.shouldStop { break }
                runtime.eval(instruction) {
                    instruction.evaluate(runtime)
                }
            }
        }
    }
    
    
    public func analyze(analyzer: Analyzer) {
        for child in children {
            child.analyze(analyzer)
        }
    }
}