//
//  InstructionNode.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public final class InstructionNode {
    public private(set) var content : InstructionContent
    public private(set) weak var parent : InstructionNode? {
        didSet {
            self.depth = (parent?.depth ?? -1) + 1
        }
    }
    private var depth : Int {
        didSet {
            if case .Group(_, let children) = content {
                for c in children {
                    c.depth = depth + 1
                }
            }
        }
    }
    
    public init(parent: InstructionNode? = nil) {
        self.parent = parent
        self.content = .Null
        self.depth = (parent?.depth ?? -1) + 1
    }
    
    public init(parent: InstructionNode? = nil, instruction: Instruction) {
        self.parent = parent
        self.content = .Single(instruction)
        self.depth = (parent?.depth ?? -1) + 1
    }
    
    public init(parent: InstructionNode? = nil, group: GroupInstruction, children: [InstructionNode] = []) {
        self.parent = parent
        self.content = .Group(group, children)
        self.depth = (parent?.depth ?? -1) + 1
    }

    private init(parent: InstructionNode? = nil, content: InstructionContent) {
        self.parent = parent
        self.content = content
        self.depth = (parent?.depth ?? -1) + 1

        if case .Group(_, let children) = content {
            for c in children {
                c.parent = self
            }
        }
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

    public func prepend(sibling node: InstructionNode) -> Bool {
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
        children.insert(node, atIndex: index)
        parent.content = .Group(group, children)
        return true

    }
}

extension InstructionNode {
    public func mergedWith<I where I:Instruction>(instruction: I, force: Bool) -> InstructionNode? {

        guard case .Single(let base) = content else {
            return nil
        }

        guard let typedBase = base as? I else {
            return nil
        }

        return typedBase.mergeWith(instruction, force: force).map { InstructionNode(instruction: $0) }
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

    public func replaceWith(instruction: GroupInstruction) {
        let children : [InstructionNode]

        if case .Group(_, let chil) = self.content {
            children = chil
        } else {
            children = [InstructionNode(parent: self)]
        }

        content = InstructionContent.Group(instruction, children)
    }

    public func replaceWith(node: InstructionNode) {
        if case .Single(let instruction) = node.content {
            content = InstructionContent.Single(instruction)
        }
    }
}

extension InstructionNode {

    public func unwrap() -> Bool {
        guard case .Group(_, let children) = self.content else {
            return false
        }

        for c in children.suffixFrom(1) {
            self.prepend(sibling: c)
        }

        return self.removeFromParent()
    }

    public func isDeeperThan(depth: Int) -> Bool {
        if self.depth > depth {
            return true
        }

        if case .Group(_, let children) = self.content {
            for c in children {
                if c.isDeeperThan(depth) {
                    return true
                }
            }
        }

        return false
    }

    public func wrapIn(instruction: GroupInstruction) {
        if case .Null = content {
            return
        }
        if isDeeperThan(2) {
            return
        }

        content = .Group(instruction, [
            InstructionNode(parent: self),
            InstructionNode(parent: self, content: content)]
        )
    }
}
extension InstructionNode {

    public func hasAncestor(node : InstructionNode) -> Bool {
        guard let parent = self.parent else {
            return false
        }

        return parent === node || parent.hasAncestor(node)
    }
}

extension InstructionNode {

    public var isDegenerated : Bool {
        switch content {
        case .Null:
            return true
        case .Group(let instruction, let children):
            return children.isEmpty || instruction.isDegenerated
        case .Single(let instruction):
            return instruction.isDegenerated
        }
    }

}

extension InstructionNode : Evaluatable {
    public func evaluate<T:Runtime where T.Ev == InstructionNode>(runtime: T) {
        switch content {
        case .Null:
            runtime.eval(self) { _ in

            }
        case .Single(let instruction):
            runtime.eval(self) { r in
                instruction.evaluate(r)
            }
        case .Group(let group, let children):
            runtime.eval(self) { r in
                group.evaluate(r, withChildren: children)
            }
        }

    }
}

extension InstructionNode : Analyzable {
    public func analyze<T:Analyzer>(analyzer: T) {
        switch content {
        case .Null:
            analyzer.publish(self, label: "Null")
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

extension InstructionNode {
    public var instruction : Any? {
        switch content {
        case .Null:
            return nil
        case .Single(let instruction):
            return instruction
        case .Group(let group, _):
            return group
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

    var isDegenerated : Bool { get }

    func mergeWith(other: Instruction, force: Bool) -> Instruction?
}


public protocol GroupInstruction : Labeled {
    
    func evaluate<T:Runtime where T.Ev==InstructionNode>(runtime: T, withChildren: [InstructionNode])
    
    func analyze<T:Analyzer>(analyzer: T)

    var target : FormIdentifier? { get }

    var isDegenerated : Bool { get }
}

public protocol Mergeable {
    func mergeWith(other: Self, force: Bool) -> Self?
}

extension Instruction where Self : Mergeable {
    public func mergeWith(other: Instruction, force: Bool) -> Instruction? {
        guard let typed = other as? Self else {
            return nil
        }

        return self.mergeWith(typed, force: force)
    }
}
