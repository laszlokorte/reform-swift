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
    case Idle
    case Creating(original: InstructionNode, InstructionNode)
    case Amending(original: InstructionNode, InstructionNode)
    case Fixing(original: InstructionNode, InstructionNode)
}

public final class InstructionCreator {
    private var state : CreationState = .Idle

    let stage : Stage
    let focus : InstructionFocus
    let intend : (commit: Bool) -> ()
    
    public init(stage: Stage, focus: InstructionFocus, intend: (commit: Bool) -> ()) {
        self.stage = stage
        self.focus = focus
        self.intend = intend
    }

    var target : FormIdentifier? {
        switch state {
        case .Idle:
            return nil
        case .Creating(_, let node):
            return node.target
        case .Amending(_, let node):
            return node.target
        case .Fixing(_, let node):
            return node.target
        }
    }
    
    func beginCreation<I:Instruction>(instruction : I) {
        switch state {
        case .Idle:
            if let focused = focus.current {
                if stage.error != nil,
                    let fixed = merge(focused, instruction: instruction, force: true) {
                        let node = fixed
                        focused.append(sibling: node)
                        focused.removeFromParent()
                        focus.current = node
                        state = .Fixing(original: focused, node)
                } else if let merged = merge(focused, instruction: instruction) {
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
                
                intend(commit: false)
            }

        default:
            break
        }
    }
    
    func cancel() {
        switch state {
        case .Creating(let original, let node):
            focus.current = original
            node.removeFromParent()
            state = .Idle
            intend(commit: false)
        case .Amending(let original, let node):
            focus.current = original
            node.prepend(sibling: original)
            node.removeFromParent()
            state = .Idle
            intend(commit: false)

        case .Fixing(let original, let node):
            focus.current = original
            node.prepend(sibling: original)
            node.removeFromParent()
            state = .Idle
            intend(commit: false)
        case .Idle:
            break
        }
    }
    
    func update<I:Instruction>(instruction: I) {
        switch state {
        case .Creating(let original, let node):
            if let merged = merge(original, instruction: instruction) {
                node.replaceWith(merged)
                original.removeFromParent()
                focus.current = node
                state = .Amending(original: original, node)
            } else {
                node.replaceWith(instruction)
            }
            intend(commit: false)
        case .Amending(let original, let node):
            if let merged = merge(original, instruction: instruction) {
                node.replaceWith(merged)
            } else {
                node.replaceWith(instruction)
                node.prepend(sibling: original)
                focus.current = node
                state = .Creating(original: original, node)
            }
            intend(commit: false)
        case .Idle:
            break
        case .Fixing(let original, let node):
            if let fixed = merge(original, instruction: instruction, force: true) {
                node.replaceWith(fixed)
            }
            intend(commit: false)
        }
    }
    
    func commit() {
        switch state {
        case .Creating(let original, let node):
            if node.isDegenerated {
                focus.current = original
                node.removeFromParent()
                intend(commit: false)
            } else {
                intend(commit: true)
            }

            state = .Idle
        case .Amending(let original, let node):
            if node.isDegenerated {
                focus.current = original
                node.prepend(sibling: original)
                node.removeFromParent()
                intend(commit: false)
            } else {
                intend(commit: true)
            }

            state = .Idle
        case .Fixing(let original, let node):
            if node.isDegenerated {
                focus.current = original
                node.prepend(sibling: original)
                node.removeFromParent()
                intend(commit: false)
            } else {
                intend(commit: true)
            }

            state = .Idle
        case .Idle:
            break
        }
    }

    func merge<I:Instruction>(node : InstructionNode, instruction : I, force: Bool = false) -> InstructionNode? {
        return node.mergedWith(instruction, force: force)
    }
}