//
//  InstructionNode.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public class InstructionNode {
    private var content : InstructionContent
    public private(set) var parent : InstructionNode?
    
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
    
    public func append(child node: InstructionNode) -> Bool {
        switch content {
        case .Null:
            return false
        case .Single(_):
            return false
        case .Group(let group, var children):
            children.append(node)
            content = .Group(group, children)
            return true
        }
    }
    
    public func append(sibling node: InstructionNode) -> Bool {
        guard let parent = parent else {
            return false
        }
        
        switch parent.content {
        case .Null:
            return false
        case .Single(_):
            return false
        case .Group(let group, var children):
            guard let index = children.indexOf({$0===self}) else {
                return false
            }
            children.insert(node, atIndex: index)
            content = .Group(group, children)
            return true
        }
    }
}

extension InstructionNode {
    
    public func removeFromParent() -> Bool {
        guard let parent = self.parent,
            case .Group(let node, let children) = parent.content else {
                return false
        }
        
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
    public func evaluate(runtime: Runtime) {
        switch content {
        case .Null: break
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
    public func analyze(analyzer: Analyzer) {
        switch content {
        case .Null:
            analyzer.publish(self, label: "Null")
            break
        case .Single(let instruction):
            analyzer.publish(self, label: instruction.getDescription(analyzer))
        case .Group(let group, let children):
            analyzer.publish(self, label: group.getDescription(analyzer)) {
                for c in children {
                    c.analyze(analyzer)
                }
            }
        }
    }
}


private enum InstructionContent {
    case Null
    case Single(Instruction)
    case Group(GroupInstruction, [InstructionNode])
}

public protocol Instruction : Labeled {
    func evaluate(runtime: Runtime)
    
    func analyze(analyzer: Analyzer)
    
    var target : FormIdentifier? { get }
}


public protocol GroupInstruction : Labeled {
    
    var target : FormIdentifier? { get }
    
    func evaluate(runtime: Runtime, withChildren: [InstructionNode])
    
    func analyze(analyzer: Analyzer)
}