//
//  WorkingState.swift
//  ReformTools
//
//  Created by Laszlo Korte on 20.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

private enum CreationState {
    case idle
    case creating(original: InstructionNode, InstructionNode)
    case amending(original: InstructionNode, InstructionNode)
    case fixing(original: InstructionNode, InstructionNode)
}

public final class InstructionCreator {
    private var state : CreationState = .idle

    let stage : Stage
    let focus : InstructionFocus
    let intend : (_ commit: Bool) -> ()
    
    public init(stage: Stage, focus: InstructionFocus, intend: @escaping (_ commit: Bool) -> ()) {
        self.stage = stage
        self.focus = focus
        self.intend = intend
    }

    var target : FormIdentifier? {
        switch state {
        case .idle:
            return nil
        case .creating(_, let node):
            return node.target
        case .amending(_, let node):
            return node.target
        case .fixing(_, let node):
            return node.target
        }
    }
    
    func beginCreation<I:Instruction>(_ instruction : I) {
        switch state {
        case .idle:
            if let focused = focus.current {
                if stage.error != nil,
                    let fixed = merge(focused, instruction: instruction, force: true) {
                        let node = fixed
                        _ = focused.append(sibling: node)
                        focused.removeFromParent()
                        focus.current = node
                        state = .fixing(original: focused, node)
                } else if let merged = merge(focused, instruction: instruction) {
                    let node = merged
                    _ = focused.append(sibling: node)
                    focused.removeFromParent()
                    focus.current = node
                    state = .amending(original: focused, node)
                } else {
                    let node = InstructionNode(instruction: instruction)
                    _ = focused.append(sibling: node)
                    focus.current = node
                    state = .creating(original: focused, node)
                }
                
                intend(false)
            }

        default:
            break
        }
    }
    
    func cancel() {
        switch state {
        case .creating(let original, let node):
            focus.current = original
            node.removeFromParent()
            state = .idle
            intend(false)
        case .amending(let original, let node):
            focus.current = original
            _ = node.prepend(sibling: original)
            node.removeFromParent()
            state = .idle
            intend(false)

        case .fixing(let original, let node):
            focus.current = original
            _ = node.prepend(sibling: original)
            node.removeFromParent()
            state = .idle
            intend(false)
        case .idle:
            break
        }
    }
    
    func update<I:Instruction>(_ instruction: I) {
        switch state {
        case .creating(let original, let node):
            if let merged = merge(original, instruction: instruction) {
                node.replaceWith(merged)
                original.removeFromParent()
                focus.current = node
                state = .amending(original: original, node)
            } else {
                node.replaceWith(instruction)
            }
            intend(false)
        case .amending(let original, let node):
            if let merged = merge(original, instruction: instruction) {
                node.replaceWith(merged)
            } else {
                node.replaceWith(instruction)
                _ = node.prepend(sibling: original)
                focus.current = node
                state = .creating(original: original, node)
            }
            intend(false)
        case .idle:
            break
        case .fixing(let original, let node):
            if let fixed = merge(original, instruction: instruction, force: true) {
                node.replaceWith(fixed)
            }
            intend(false)
        }
    }
    
    func commit() {
        switch state {
        case .creating(let original, let node):
            if node.isDegenerated {
                focus.current = original
                node.removeFromParent()
                intend(false)
            } else {
                intend(true)
            }

            state = .idle
        case .amending(let original, let node):
            if node.isDegenerated {
                focus.current = original
                _ = node.prepend(sibling: original)
                node.removeFromParent()
                intend(false)
            } else {
                intend(true)
            }

            state = .idle
        case .fixing(let original, let node):
            if node.isDegenerated {
                focus.current = original
                _ = node.prepend(sibling: original)
                node.removeFromParent()
                intend(false)
            } else {
                intend(true)
            }

            state = .idle
        case .idle:
            break
        }
    }

    func merge<I:Instruction>(_ node : InstructionNode, instruction : I, force: Bool = false) -> InstructionNode? {
        return node.mergedWith(instruction, force: force)
    }
}
