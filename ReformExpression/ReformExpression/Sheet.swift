//
//  Sheet.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum DefinitionValue {
    case primitive(Value)
    case array([Value])
    case expr(Expression)
    case invalid(String, ShuntingYardError)
}

extension DefinitionValue {
    func collectedDependencies() -> Set<ReferenceId> {
        switch self {
        case .expr(let expr):
            return expr.collectedDependencies()
        default:
            return Set<ReferenceId>()
        }
    }
}

extension DefinitionValue {
    private func withSubstitutedReference(_ reference: ReferenceId, value: Value) -> DefinitionValue {
        switch self {
        case .expr(let expr):
            return .expr(expr.withSubstitutedReference(reference, value: value))
        default:
            return self
        }
    }
}

extension Expression {
    private func withSubstitutedReference(_ reference: ReferenceId, value: Value) -> Expression {
        switch self {
        case .constant(let v):
            return .constant(v)
        case .namedConstant(let name, let v):
            return .namedConstant(name, v)
        case .reference(let id) where id == reference:
            return .constant(value)
        case .reference(let id):
            return .reference(id: id)
        case .unary(let op, let sub):
            return .unary(op, sub.withSubstitutedReference(reference, value: value))
        case .binary(let op, let left, let right):
            return .binary(op, left.withSubstitutedReference(reference, value: value), right.withSubstitutedReference(reference, value: value))
        case .call(let op, let args):
            return .call(op, args.map { $0.withSubstitutedReference(reference, value: value) })
        }
    }
}

extension Expression {
    func collectedDependencies() -> Set<ReferenceId> {
        switch self {
        case .reference(let id):
            var set = Set<ReferenceId>()
            set.insert(id)
            return set
        case .unary(_, let sub):
            return sub.collectedDependencies()
        case .binary(_, let left, let right):
                return left.collectedDependencies().union(right.collectedDependencies())

        case .call(_, let args):
            return args.reduce(Set<ReferenceId>()) { acc, next in
                acc.union(next.collectedDependencies())
            }
        default:
            return Set<ReferenceId>()
        }
    }
}


final public class Definition {
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
    private func replaceOccurencesOf(_ reference: ReferenceId, with: Value) {
        value = value.withSubstitutedReference(reference, value: with)
    }
}

protocol DefinitionSheet {
    var sortedDefinitions : [Definition] { get }
    
    func definitionWithName(_ name: String) -> Definition?
    
    func definitionWithId(_ id: ReferenceId) -> Definition?
}

public protocol Sheet : class {
    var sortedDefinitions : (Set<ReferenceId>, [Definition]) { get }
    var referenceIds : Set<ReferenceId> { get }
    
    func definitionWithName(_ name:String) -> Definition?
    
    func definitionWithId(_ id:ReferenceId) -> Definition?
    
    func replaceOccurencesOf(_ reference: ReferenceId, with: Value)
}

public protocol EditableSheet : Sheet {
    func addDefinition(_ definition: Definition)
    
    func removeDefinition(_ definition: ReferenceId)
}

public final class BaseSheet : EditableSheet {
    private var definitions: [Definition] = []
    
    public init() {
    
    }
    
    public var referenceIds : Set<ReferenceId> {
        return Set(definitions.map { $0.id })
    }
    
    public var sortedDefinitions : (Set<ReferenceId>, [Definition]) {
        return sortDefinitions(definitions)
    }
    
    public func definitionWithName(_ name:String) -> Definition? {
        for def in definitions {
            if def.name == name {
                return def
            }
        }
        
        return nil
    }
    
    public func definitionWithId(_ id:ReferenceId) -> Definition? {
        for def in definitions {
            if def.id == id {
                return def
            }
        }
        
        return nil
    }
    
    public func replaceOccurencesOf(_ reference: ReferenceId, with: Value) {
        for def in definitions {
            def.replaceOccurencesOf(reference, with: with)
        }
    }
    
    public func addDefinition(_ definition: Definition) {
        definitions.append(definition)
    }
    
    public func removeDefinition(_ id: ReferenceId) {
        if let index = definitions.index(where: { $0.id == id }) {
            definitions.remove(at: index)
        }
    }
}

public final class DerivedSheet : EditableSheet {
    private var definitions: [Definition] = []
    private let baseSheet : Sheet
    
    init(base: Sheet) {
        self.baseSheet = base
    }
    
    public var referenceIds : Set<ReferenceId> {
        return Set(definitions.map { $0.id }).union(baseSheet.referenceIds)
    }
    
    public var sortedDefinitions : (Set<ReferenceId>, [Definition]) {
        return sortDefinitions(referenceIds.flatMap({ definitionWithId($0) }))
    }
    
    public func definitionWithName(_ name:String) -> Definition? {
        for def in definitions {
            if def.name == name {
                return def
            }
        }
        
        return baseSheet.definitionWithName(name)
    }
    
    public func definitionWithId(_ id:ReferenceId) -> Definition? {
        for def in definitions {
            if def.id == id {
                return def
            }
        }
        
        return baseSheet.definitionWithId(id)
    }
    
    public func replaceOccurencesOf(_ reference: ReferenceId, with: Value) {
        for def in definitions {
            def.replaceOccurencesOf(reference, with: with)
        }
    }
    
    public func addDefinition(_ definition: Definition) {
        definitions.append(definition)
    }
    
    public func removeDefinition(_ id: ReferenceId) {
        if let index = definitions.index(where: { $0.id == id }) {
            definitions.remove(at: index)
        }
    }
}



func sortDefinitions(_ definitions: [Definition]) -> (Set<ReferenceId>, [Definition]) {
    
    var nodes = [ReferenceId:Node<ReferenceId, Definition>]()
    var duplicates = Set<ReferenceId>()
    
    for d in definitions {
        if nodes.keys.contains(d.id) {
            duplicates.insert(d.id)
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
    
    return (duplicates, topologicallySorted(Array(nodes.values)).map { node -> Definition in
        return node.data
    })
}
