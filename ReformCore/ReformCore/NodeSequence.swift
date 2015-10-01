//
//  NodeSequence.swift
//  ReformCore
//
//  Created by Laszlo Korte on 01.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct InstructionNodeSequence {
    var nodes : [InstructionNode]

    public init?(var nodes: [InstructionNode]) {
        guard let firstParent = nodes.first?.parent else {
            return nil
        }

        guard case .Group(_, let children) = firstParent.content else {
            return nil
        }

        for node in nodes {
            guard node.parent === firstParent else {
                return nil
            }
        }

        nodes.sortInPlace { a, b in
            return (children.indexOf { $0 === a })! <
            (children.indexOf { $0 === b })!
        }

        nodes = nodes.filter {
            return !$0.isEmpty
        }

        if nodes.isEmpty {
            return nil
        }

        let sorted : (Bool, InstructionNode?) = nodes.reduce((true, Optional<InstructionNode>.None)) { (prev, current) in
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
    public func wrapIn(instruction: GroupInstruction) {
        print("wrap")
    }
}