//
//  SelectionTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformCore
import ReformStage

public final class SelectionTool : Tool {
    enum State
    {
        case idle
        case selecting(entity: Entity?, cycle: Int, old: Set<FormIdentifier>)
        case multiSelect(from: Vec2d, to: Vec2d, old: Set<FormIdentifier>)
    }

    enum ChangeMode {
        case replace
        case xor

        func combine(_ old: Set<FormIdentifier>, with: [FormIdentifier]) -> Set<FormIdentifier> {
            switch self {
            case .replace:
                return Set().union(with)
            case .xor:
                return old.symmetricDifference(with)
            }
        }
    }

    var state : State = .idle {
        didSet {
            update(state)
        }
    }

    var changeMode : ChangeMode = .replace
    
    let stage : Stage
    let selection : FormSelection
    let selectionUI : SelectionUI
    
    let entityFinder : EntityFinder

    let indend: () -> ()

    public init(stage: Stage, selection: FormSelection, selectionUI: SelectionUI, indend: @escaping () -> ()) {
        self.stage = stage
        self.selection = selection
        self.selectionUI = selectionUI
        self.indend = indend
        
        self.entityFinder = EntityFinder(stage: stage)
    }
    
    public func setUp() {
        changeMode = .replace
        state = .idle
        selectionUI.state = .show(selection)
    }
    
    public func tearDown() {
        selectionUI.state = .hide
        state = .idle
    }
    
    public func refresh() {
        
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        selection.clear()
        state = .idle
        indend()
    }

    public func process(_ input: Input, atPosition position: Vec2d, withModifier: Modifier) {
        changeMode = withModifier.isStreight ? .xor : .replace
        
        switch state {
        case .selecting(_, let cycle, let old):
            switch input {
            case .cycle:
                let entities = entitiesNear(position)
                if entities.count > 0 {
                    state = .selecting(entity: entities[(cycle+1)%entities.count], cycle: cycle+1, old: old)
                }
            case .release:
                state = .idle
            case .press, .toggle, .modifierChange, .move:
                break
            }
        case .idle:
            switch input {
            case .press:
                let entities = entitiesNear(position)
                if entities.isEmpty || withModifier.contains(.Glomp) {
                    state = .multiSelect(from: position, to: position, old: selection.selected)
                } else if changeMode == .replace, let
                    previous = selection.one,
                    let index = entities.index(where: {$0.id.runtimeId == previous}) {
                    state = .selecting(entity: entities[index], cycle: index, old: selection.selected)
                    
                } else if changeMode == .xor || selection.selected.intersection(entities.map{$0.id.runtimeId}).isEmpty {
                    state = .selecting(entity: entities.first, cycle: 0, old: selection.selected)
                }
            case .release, .cycle, .toggle, .modifierChange, .move:
                break
            }

        case .multiSelect(let from, _, let old):
            switch input {
            case .move:
                state = .multiSelect(from: from, to: position, old: old)
            case .release:
                state = .idle
            case .press, .toggle, .modifierChange, .cycle:
                break
            }
        }
    }
    
    private func entitiesNear(_ position: Vec2d) -> [Entity] {
        let query = EntityQuery(filter: .any, location: .near(position, distance: 0))
        return entityFinder.getEntities(query)
    }

    private func entitiesInside(min: Vec2d, max: Vec2d) -> [Entity] {
        let query = EntityQuery(filter: .any, location: .aabb(AABB2d(min: min, max: max)))
        return entityFinder.getEntities(query)
    }
    
    private func update(_ state: State) {

        switch state {
        case .selecting(let entity, _, let old):
            selection.select(changeMode.combine(old, with: entity.map{[$0.id.runtimeId]} ?? []))
            indend()

            fallthrough
        case .idle:
            selectionUI.rect = .hide
        case .multiSelect(let from, let to, let old):
            selection.select(changeMode.combine(old, with: entitiesInside(min: from, max: to).map{$0.id.runtimeId}))
            selectionUI.rect = .show(from, to)
            indend()

        }
    }
}
