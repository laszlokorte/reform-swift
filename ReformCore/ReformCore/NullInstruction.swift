//
//  NullInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class NullInstruction : Instruction {

    public var parent : InstructionGroup? = nil
    public let target : FormIdentifier? = nil
    
    
    public func evaluate(runtime: Runtime) {
        
    }
    
    
    public func analyze(analyzer: Analyzer) {
        analyzer.publish(self, label: "Null")
    }
    
}