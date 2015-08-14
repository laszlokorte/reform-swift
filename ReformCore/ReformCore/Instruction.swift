//
//  Instruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public protocol Instruction : class, Analyzable {
    func evaluate(runtime: Runtime)
    
    var parent : InstructionGroup? { get set }
    
    var target : FormIdentifier? { get }
}

public func ==(lhs: Instruction, rhs: Instruction) -> Bool {
    return lhs === rhs
}

public protocol InstructionGroup : Instruction {
    var count : Int { get }
    
    subscript(index : Int) -> Instruction { get }
    
    func indexOf(instruction : Instruction) -> Int?
    
    func insert(instruction : Instruction, relative : Instruction, pos: InstructionPosition)
    
    func append(instruction : Instruction)
    
    func remove(instruction: Instruction)
}


public enum InstructionPosition {
    case Before
    case After
    
    var offset : Int {
        switch self {
        case .Before: return 0
        case .After: return 1
        }
    }
}