//
//  WorkingState.swift
//  ReformTools
//
//  Created by Laszlo Korte on 20.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore

private enum CreationState {
    case Idle
    case Creating(original: InstructionNode, InstructionNode)
    case Amending(original: InstructionNode, InstructionNode)
}

public final class InstructionCreator {
    private var state : CreationState = .Idle
    
    let focus : InstructionFocus
    let notifier : (Bool) -> ()
    
    public init(focus: InstructionFocus, notifier: (Bool) -> ()) {
        self.focus = focus
        self.notifier = notifier
    }
    
    func beginCreation<I:Instruction>(instruction : I) {
        if case .Idle = state, let focused = focus.current {
            if let merged = focused.mergedWith(instruction) {
                let node = merged
                focused.append(sibling: node)
                focused.removeFromParent()
                focus.current = node
                state = .Amending(original: focused, node)
            } else {
                let node = InstructionNode(instruction: instruction)
                focused.append(sibling: node)
                focus.current = node
                state = .Creating(original: focused, node)
            }

            notifier(false)
        }
    }
    
    func cancel() {
        if case .Creating(let original, let node) = state {
            focus.current = original
            node.removeFromParent()
            state = .Idle
            notifier(false)
        } else if case .Amending(let original, let node) = state {
            focus.current = node.previous
            node.prepend(sibling: original)
            node.removeFromParent()
            state = .Idle
            notifier(false)
        }
    }
    
    func update<I:Instruction>(instruction: I) {
        if case .Creating(let original, let node) = state {
            if let merged = original.mergedWith(instruction) {
                node.replaceWith(merged)
                original.removeFromParent()
                focus.current = node
                state = .Amending(original: original, node)
            } else {
                node.replaceWith(instruction)
            }
            notifier(false)
        } else if case .Amending(let original, let node) = state {
            if let merged = original.mergedWith(instruction) {
                node.replaceWith(merged)
            } else {
                node.replaceWith(instruction)
                node.prepend(sibling: original)
                focus.current = node
                state = .Creating(original: original, node)
            }
            notifier(false)
        }
    }
    
    func commit() {
        if case .Creating(let original, let node) = state {
            if node.isDegenerated {
                focus.current = node.previous
                node.removeFromParent()
                notifier(false)
            } else {
                notifier(true)
            }

            state = .Idle
        } else if case .Amending(let original, let node) = state {
            if node.isDegenerated {
                focus.current = original
                node.prepend(sibling: original)
                node.removeFromParent()
                notifier(false)
            } else {
                notifier(true)
            }

            state = .Idle
        }
    }
}