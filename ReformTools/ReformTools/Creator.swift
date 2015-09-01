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

public class InstructionCreator {
    private var state : CreationState = .Idle
    
    let focus : InstructionFocus
    let notifier : (Bool) -> ()
    
    public init(focus: InstructionFocus, notifier: (Bool) -> ()) {
        self.focus = focus
        self.notifier = notifier
    }
    
    func beginCreation(instruction : Instruction) {
        if case .Idle = state, let focused = focus.current {
            let node = InstructionNode(instruction: instruction)
            focused.append(sibling: node)
            focus.current = node
            state = .Creating(node)
            notifier(false)
        }
    }
    
    func cancel() {
        if case .Creating(let node) = state {
            focus.current = node.previous
            node.removeFromParent()
            state = .Idle
            notifier(false)
        }
    }
    
    func update(instruction: Instruction) {
        if case .Creating(let node) = state {
            node.replaceWith(instruction)
            notifier(false)
        }
    }
    
    func commit() {
        notifier(true)
        state = .Idle
    }
}