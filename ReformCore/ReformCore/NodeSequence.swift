//
//  NodeSequence.swift
//  ReformCore
//
//  Created by Laszlo Korte on 01.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct InstructionNodeSequence {
    var nodes : [InstructionNode]

    public init?(nodes: [InstructionNode]) {
        var nodes = nodes
        guard let firstParent = nodes.first?.parent else {
            return nil
        }

        guard case .group(_, let children) = firstParent.content else {
            return nil
        }

        for node in nodes {
            guard node.parent === firstParent else {
                return nil
            }
        }

        nodes.sort { a, b in
            return (children.index { $0 === a })! <
            (children.index { $0 === b })!
        }

        nodes = nodes.filter {
            return !$0.isEmpty
        }

        if nodes.isEmpty {
            return nil
        }

        let sorted : (Bool, InstructionNode?) = nodes.reduce((true, Optional<InstructionNode>.none)) { (prev, current) in
            guard let prevNode = prev.1 else {
                return (true, current)
            }
            return (prev.0 && prevNode === current.previous, current)
        }

        if sorted.0 == false {
            return nil
        }

        self.nodes = nodes
    }
}

extension InstructionNodeSequence {
    public func wrapIn(_ instruction: GroupInstruction) -> Bool {
        guard let first = nodes.first else {
            return false
        }

        let group = InstructionNode(group: instruction)

        for n in nodes {
            if n.isDeeperThan(2) {
                return false
            }
        }

        _ = first.prepend(sibling: group)

        _ = group.append(child: InstructionNode())

        for n in nodes {
            n.removeFromParent()
            _ = group.append(child: n)
        }

        return true
    }
}
