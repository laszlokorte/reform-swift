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
            if case .group(_, let children) = content {
                for c in children {
                    c.depth = depth + 1
                }
            }
        }
    }
    
    public init(parent: InstructionNode? = nil) {
        self.parent = parent
        self.content = .null
        self.depth = (parent?.depth ?? -1) + 1
    }
    
    public init(parent: InstructionNode? = nil, instruction: Instruction) {
        self.parent = parent
        self.content = .single(instruction)
        self.depth = (parent?.depth ?? -1) + 1
    }
    
    public init(parent: InstructionNode? = nil, group: GroupInstruction, children: [InstructionNode] = []) {
        self.parent = parent
        self.content = .group(group, children)
        self.depth = (parent?.depth ?? -1) + 1
    }

    private init(parent: InstructionNode? = nil, content: InstructionContent) {
        self.parent = parent
        self.content = content
        self.depth = (parent?.depth ?? -1) + 1

        if case .group(_, let children) = content {
            for c in children {
                c.parent = self
            }
        }
    }
    
}

extension InstructionNode {
    public var isGroup : Bool {
        if case .group = content {
            return true
        } else {
            return false
        }
    }

    public var isEmpty : Bool {
        if case .null = content {
            return true
        } else {
            return false
        }
    }

    public var target : FormIdentifier? {
        guard case .single(let instruction) = content else {
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
        
        guard case .group(_, let children) = parent.content else {
            return nil
        }
        
        guard let index = children.index(where: {$0===self}) where index > 0 else {
            return nil
        }
        
        return children[index-1]
    }
}

extension InstructionNode {
    
    public func append(child node: InstructionNode) -> Bool {
        guard case .group(let group, var children) = content else {
            return false
        }
        children.append(node)
        node.parent = self
        content = .group(group, children)
        return true
        
    }
    
    public func append(sibling node: InstructionNode) -> Bool {
        guard let parent = parent else {
            return false
        }

        guard case .group(let group, var children) = parent.content else {
            return false
        }

        guard let index = children.index(where: {$0===self}) else {
            return false
        }
        node.parent = parent
        children.insert(node, at: index+1)
        parent.content = .group(group, children)
        return true

    }

    public func prepend(sibling node: InstructionNode) -> Bool {
        guard let parent = parent else {
            return false
        }

        guard case .group(let group, var children) = parent.content else {
            return false
        }

        guard let index = children.index(where: {$0===self}) else {
            return false
        }
        node.parent = parent
        children.insert(node, at: index)
        parent.content = .group(group, children)
        return true

    }
}

extension InstructionNode {
    public func mergedWith<I where I:Instruction>(_ instruction: I, force: Bool) -> InstructionNode? {

        guard case .single(let base) = content else {
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
        
        guard case .group(let node, let children) = parent.content else {
                return false
        }
        
        self.parent = nil
        parent.content = .group(node, children.filter({ $0 !== self }))
        
        return true
    }
}

extension InstructionNode {

    public func replaceWith(_ instruction: Instruction) {
        content = InstructionContent.single(instruction)
    }

    public func replaceWith(_ instruction: GroupInstruction) {
        let children : [InstructionNode]

        if case .group(_, let chil) = self.content {
            children = chil
        } else {
            children = [InstructionNode(parent: self)]
        }

        content = InstructionContent.group(instruction, children)
    }

    public func replaceWith(_ node: InstructionNode) {
        if case .single(let instruction) = node.content {
            content = InstructionContent.single(instruction)
        }
    }
}

extension InstructionNode {

    public func unwrap() -> Bool {
        guard case .group(_, let children) = self.content else {
            return false
        }

        for c in children.suffix(from: 1) {
            self.prepend(sibling: c)
        }

        return self.removeFromParent()
    }

    public func isDeeperThan(_ depth: Int) -> Bool {
        if self.depth > depth {
            return true
        }

        if case .group(_, let children) = self.content {
            for c in children {
                if c.isDeeperThan(depth) {
                    return true
                }
            }
        }

        return false
    }

    public func wrapIn(_ instruction: GroupInstruction) {
        if case .null = content {
            return
        }
        if isDeeperThan(2) {
            return
        }

        content = .group(instruction, [
            InstructionNode(parent: self),
            InstructionNode(parent: self, content: content)]
        )
    }
}
extension InstructionNode {

    public func hasAncestor(_ node : InstructionNode) -> Bool {
        guard let parent = self.parent else {
            return false
        }

        return parent === node || parent.hasAncestor(node)
    }
}

extension InstructionNode {

    public var isDegenerated : Bool {
        switch content {
        case .null:
            return true
        case .group(let instruction, let children):
            return children.isEmpty || instruction.isDegenerated
        case .single(let instruction):
            return instruction.isDegenerated
        }
    }

}

extension InstructionNode : Evaluatable {
    public func evaluate<T:Runtime where T.Ev == InstructionNode>(_ runtime: T) {
        switch content {
        case .null:
            runtime.eval(self) { _ in

            }
        case .single(let instruction):
            runtime.eval(self) { r in
                instruction.evaluate(r)
            }
        case .group(let group, let children):
            runtime.eval(self) { r in
                group.evaluate(r, withChildren: children)
            }
        }

    }
}

extension InstructionNode : Analyzable {
    public func analyze<T:Analyzer>(_ analyzer: T) {
        switch content {
        case .null:
            analyzer.publish(self, label: "Null")
        case .single(let instruction):
            analyzer.publish(self, label: instruction.getDescription(analyzer.stringifier))
            instruction.analyze(analyzer)
        case .group(let group, let children):
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
        case .null:
            return nil
        case .single(let instruction):
            return instruction
        case .group(let group, _):
            return group
        }
    }
}


public enum InstructionContent {
    case null
    case single(Instruction)
    case group(GroupInstruction, [InstructionNode])
}

public protocol Instruction : Labeled {
    func evaluate<T:Runtime>(_ runtime: T)
    
    func analyze<T:Analyzer>(_ analyzer: T)
    
    var target : FormIdentifier? { get }

    var isDegenerated : Bool { get }

    func mergeWith(_ other: Instruction, force: Bool) -> Instruction?
}


public protocol GroupInstruction : Labeled {
    
    func evaluate<T:Runtime where T.Ev==InstructionNode>(_ runtime: T, withChildren: [InstructionNode])
    
    func analyze<T:Analyzer>(_ analyzer: T)

    var target : FormIdentifier? { get }

    var isDegenerated : Bool { get }
}

public protocol Mergeable {
    func mergeWith(_ other: Self, force: Bool) -> Self?
}

extension Instruction where Self : Mergeable {
    public func mergeWith(_ other: Instruction, force: Bool) -> Instruction? {
        guard let typed = other as? Self else {
            return nil
        }

        return self.mergeWith(typed, force: force)
    }
}
