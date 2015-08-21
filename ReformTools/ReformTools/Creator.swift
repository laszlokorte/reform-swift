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
    let notifier : ChangeNotifier
    
    public init(focus: InstructionFocus, notifier: ChangeNotifier) {
        self.focus = focus
        self.notifier = notifier
    }
    
    func beginCreation(instruction : Instruction) {
        if case .Idle = state, let focused = focus.current {
            let node = InstructionNode(instruction: instruction)
            focused.append(sibling: node)
            focus.current = node
            state = .Creating(node)
            notifier()
        }
    }
    
    func cancel() {
        if case .Creating(let node) = state {
            focus.current = node.previous
            node.removeFromParent()
            state = .Idle
            notifier()
        }
    }
    
    func update(instruction: Instruction) {
        if case .Creating(let node) = state {
            node.replaceWith(instruction)
            notifier()
        }
    }
    
    func commit() {
        state = .Idle
    }
}