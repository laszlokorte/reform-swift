//
//  NullInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

class NullInstruction : Instruction {

    var parent : InstructionGroup? = nil
    let target : FormIdentifier? = nil
    
    
    func evaluate(runtime: Runtime) {
        
    }
    
    
    func analyze(analyzer: Analyzer) {
        analyzer.publish(self, label: "Null")
    }
    
}