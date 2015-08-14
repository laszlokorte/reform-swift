//
//  Sheet.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum DefinitionValue {
    case Primitive(Value)
    case Array([Value])
    case Expr(Expression)
    case Invalid(String, ShuntingYardError)
}

extension DefinitionValue {
    func collectedDependencies() -> Set<ReferenceId> {
        switch self {
        case .Expr(let expr):
            return expr.collectedDependencies()
        default:
            return Set<ReferenceId>()
        }
    }
}

extension DefinitionValue {
    private func withSubstitutedReference(reference: ReferenceId, value: Value) -> DefinitionValue {
        switch self {
        case .Expr(let expr):
            return .Expr(expr.withSubstitutedReference(reference, value: value))
        default:
            return self
        }
    }
}

extension Expression {
    private func withSubstitutedReference(reference: ReferenceId, value: Value) -> Expression {
        switch self {
        case .Constant(let v):
            return .Constant(v)
        case .NamedConstant(let name, let v):
            return .NamedConstant(name, v)
        case .Reference(let id) where id == reference:
            return .Constant(value)
        case .Reference(let id):
            return .Reference(id: id)
        case .Unary(let op, let sub):
            return .Unary(op, sub.withSubstitutedReference(reference, value: value))
        case .Binary(let op, let left, let right):
            return .Binary(op, left.withSubstitutedReference(reference, value: value), right.withSubstitutedReference(reference, value: value))
        case .Call(let op, let args):
            return .Call(op, args.map { $0.withSubstitutedReference(reference, value: value) })
        }
    }
}

extension Expression {
    func collectedDependencies() -> Set<ReferenceId> {
        switch self {
        case .Reference(let id):
            var set = Set<ReferenceId>()
            set.insert(id)
            return set
        case .Unary(_, let sub):
            return sub.collectedDependencies()
        case .Binary(_, let left, let right):
                return left.collectedDependencies().union(right.collectedDependencies())

        case .Call(_, let args):
            return args.reduce(Set<ReferenceId>()) { acc, next in
                acc.union(next.collectedDependencies())
            }
        default:
            return Set<ReferenceId>()
        }
    }
}


public class Definition {
    let id: ReferenceId
    var name: String
    var value : DefinitionValue
    
    init(id: ReferenceId, name: String, value : DefinitionValue) {
        self.id = id
        self.name = name
        self.value = value
    }
}

extension Definition {
    private func replaceOccurencesOf(reference: ReferenceId, with: Value) {
        value = value.withSubstitutedReference(reference, value: with)
    }
}

public class Sheet {
    var definitions: [Definition] = []
    var _sortedDefinitions: [Definition] = []
    
    var sortedDefinitions : [Definition] {
        prepareForSolving()
        return _sortedDefinitions
    }
    
    private var _duplicates = Set<ReferenceId>()
    private var _unresolved = Set<ReferenceId>()
    
    public func definitionWithName(name:String) -> Definition? {
        for def in definitions {
            if def.name == name {
                return def
            }
        }
        
        return nil
    }
    
    public func definitionWithId(id:ReferenceId) -> Definition? {
        for def in definitions {
            if def.id == id {
                return def
            }
        }
        
        return nil
    }
    
    func replaceOccurencesOf(reference: ReferenceId, with: Value) {
        for def in definitions {
            def.replaceOccurencesOf(reference, with: with)
        }
    }
    
    func prepareForSolving() {

        var nodes = [ReferenceId:Node<ReferenceId, Definition>]()
        
        for d in definitions {
            if nodes.keys.contains(d.id) {
                _duplicates.insert(d.id)
            } else {
                nodes[d.id] = Node(id: d.id, data: d)
            }
        }
        
        for (_, node) in nodes {
            let dependencies = node.data.value.collectedDependencies().flatMap({ nodes[$0] })
            for d in dependencies {
                d.outgoing.insert(node)
            }
        }
        
        _sortedDefinitions = topologicallySorted(nodes.values.array).map { node -> Definition in
            return node.data
        }
    }
}
