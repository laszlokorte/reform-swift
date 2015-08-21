//
//  WorkingState.swift
//  ReformTools
//
//  Created by Laszlo Korte on 20.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

private enum CreationState {
    case Creating(InstructionNode)
    case Idle
}

class InstructionCreator {
    private var state : CreationState = .Idle
    
    let focus : InstructionFocus
    
    init(focus: InstructionFocus) {
        self.focus = focus
    }
    
    func beginCreation(instruction : Instruction) {
        if case .Idle = state, let focused = focus.current {
            let node = InstructionNode(instruction: instruction)
            focused.append(sibling: node)
            focus.current = node
            state = .Creating(node)
        }
    }
    
    func cancel() {
        if case .Creating(let node) = state {
            focus.current = node.previous
            node.removeFromParent()
            state = .Idle
        }
    }
    
    func update(instruction: Instruction) {
        if case .Creating(let node) = state {
            node.replaceWith(instruction)
        }
    }
    
    func commit() {
        state = .Idle
    }
}