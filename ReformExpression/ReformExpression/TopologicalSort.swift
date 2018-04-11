//
//  TopologicalSort.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 10.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final class Node<I,T> : Hashable where I : Hashable {
    let id : I
    let data : T
    var outgoing = Set<Node<I,T>>()
    var incomingCount = 0
    
    init(id: I, data: T) {
        self.data = data
        self.id = id
    }
    
    var hashValue: Int { return id.hashValue }
}

func ==<I,T>(left: Node<I,T>, right: Node<I,T>) -> Bool {
    return left.id == right.id
}

func topologicallySorted<I,T>(_ nodes: [Node<I, T>]) -> [Node<I, T>] {

    var result = [Node<I,T>]()
    var rootNodes = Set<Node<I,T>>()
    
    
    for node in nodes {
        for dep in node.outgoing {
            dep.incomingCount += 1
        }
    }
    
    rootNodes.formUnion(nodes.filter({ $0.incomingCount == 0 }))
    
    while let n = rootNodes.first {
        rootNodes.remove(n)
        result.append(n)
        
        for m in n.outgoing {
            n.outgoing.remove(m)
            m.incomingCount -= 1
            if m.incomingCount == 0 {
                rootNodes.insert(m)
            }
        }
    }
    
    return result
}
