//
//  InstructionNode.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public final class InstructionNode {
    public private(set) var content : InstructionContent
    public private(set) weak var parent : InstructionNode?
    
    public init() {
        content = .Null
    }
    
    public init(instruction: Instruction) {
        content = .Single(instruction)
    }
    
    public init(group: GroupInstruction, children: [InstructionNode] = []) {
        content = .Group(group, children)
    }
    
}

extension InstructionNode {
    public var isGroup : Bool {
        if case .Group = content {
            return true
        } else {
            return false
        }
    }

    public var isEmpty : Bool {
        if case .Null = content {
            return true
        } else {
            return false
        }
    }

    public var target : FormIdentifier? {
        guard case .Single(let instruction) = content else {
            return nil
        }

        return instruction.target
    }
}

extension InstructionNode {
    public var previous : InstructionNode? {
        guard let parent = parent else {
            return nil
        }
        
        guard case .Group(_, let children) = parent.content else {
            return nil
        }
        
        guard let index = children.indexOf({$0===self}) where index > 0 else {
            return nil
        }
        
        return children[index-1]
    }
}

extension InstructionNode {
    
    public func append(child node: InstructionNode) -> Bool {
        guard case .Group(let group, var children) = content else {
            return false
        }
        children.append(node)
        node.parent = self
        content = .Group(group, children)
        return true
        
    }
    
    public func append(sibling node: InstructionNode) -> Bool {
        guard let parent = parent else {
            return false
        }
        
        guard case .Group(let group, var children) = parent.content else {
            return false
        }
        
        guard let index = children.indexOf({$0===self}) else {
            return false
        }
        node.parent = parent
        children.insert(node, atIndex: index+1)
        parent.content = .Group(group, children)
        return true
        
    }
}

extension InstructionNode {
    
    public func removeFromParent() -> Bool {
        guard let parent = parent else {
            return false
        }
        
        guard case .Group(let node, let children) = parent.content else {
                return false
        }
        
        self.parent = nil
        parent.content = .Group(node, children.filter({ $0 !== self }))
        
        return true
    }
}

extension InstructionNode {
    
    public func replaceWith(instruction: Instruction) {
        content = InstructionContent.Single(instruction)
    }
}

extension InstructionNode : Evaluatable {
    public func evaluate<T:Runtime>(runtime: T) {
        switch content {
        case .Null:
            runtime.eval(self) {

            }
        case .Single(let instruction):
            runtime.eval(self) {
                instruction.evaluate(runtime)
            }
        case .Group(let group, let children):
            runtime.eval(self) {
                group.evaluate(runtime, withChildren: children)
            }
        }

    }
}

extension InstructionNode : Analyzable {
    public func analyze<T:Analyzer>(analyzer: T) {
        switch content {
        case .Null:
            analyzer.publish(self, label: "Null")
            break
        case .Single(let instruction):
            analyzer.publish(self, label: instruction.getDescription(analyzer.stringifier))
            instruction.analyze(analyzer)
        case .Group(let group, let children):
            analyzer.publish(self, label: group.getDescription(analyzer.stringifier)) {
                group.analyze(analyzer)
                for c in children {
                    c.analyze(analyzer)
                }
            }
        }
    }
}


public enum InstructionContent {
    case Null
    case Single(Instruction)
    case Group(GroupInstruction, [InstructionNode])
}

public protocol Instruction : Labeled {
    func evaluate<T:Runtime>(runtime: T)
    
    func analyze<T:Analyzer>(analyzer: T)
    
    var target : FormIdentifier? { get }
}


public protocol GroupInstruction : Labeled {
    
    var target : FormIdentifier? { get }
    
    func evaluate<T:Runtime>(runtime: T, withChildren: [InstructionNode])
    
    func analyze<T:Analyzer>(analyzer: T)
}