//
//  SelectionTool.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath
import ReformStage

public class SelectionTool : Tool {
    enum State
    {
        case Idle
        case Selecting(entity: Entity?, cycle: Int)
        case MultiSelect(from: Vec2d, to: Vec2d)
    }

    var state : State = .Idle {
        didSet {
            update(state)
        }
    }
    
    let stage : Stage
    let selection : FormSelection
    let selectionUI : SelectionUI
    
    let entityFinder : EntityFinder

    var xorMode = false
        
    public init(stage: Stage, selection: FormSelection, selectionUI: SelectionUI) {
        self.stage = stage
        self.selection = selection
        self.selectionUI = selectionUI
        
        self.entityFinder = EntityFinder(stage: stage)
    }
    
    public func setUp() {
        xorMode = false
        state = .Idle
        selectionUI.state = .Show(selection)
    }
    
    public func tearDown() {
        selectionUI.state = .Hide
        state = .Idle
    }
    
    public func refresh() {
        
    }
    
    public func focusChange() {
    }
    
    public func cancel() {
        selection.clear()
        state = .Idle
    }
    
    public func process(input: Input, atPosition position: Vec2d, withModifier: Modifier) {
        xorMode = withModifier.isStreight
        
        switch state {
        case .Selecting(_, let cycle):
            switch input {
            case .Cycle:
                let entities = entitiesNear(position)
                if entities.count > 0 {
                    state = .Selecting(entity: entities[(cycle+1)%entities.count], cycle: cycle+1)
                }
            case .Release:
                state = .Idle
            case .Press, .Toggle, .ModifierChange, .Move:
                break
            }
        case .Idle:
            switch input {
            case .Press:
                let entities = entitiesNear(position)
                if entities.isEmpty {
                    state = .MultiSelect(from: position, to: position)
                } else if let
                    previous = selection.one,
                    index = entities.indexOf({$0.id == previous}) {
                    state = .Selecting(entity: entities[index], cycle: index)
                    
                } else {
                    state = .Selecting(entity: entities.first, cycle: 0)
                }
            case .Release, .Cycle, .Toggle, .ModifierChange, .Move:
                break
            }

        case .MultiSelect(let from, _):
            switch input {
            case .Move:
                state = .MultiSelect(from: from, to: position)
            case .Release:
                state = .Idle
            case .Press, .Toggle, .ModifierChange, .Cycle:
                break
            }
        }
    }
    
    private func entitiesNear(position: Vec2d) -> [Entity] {
        let query = EntityQuery(filter: .Any, location: .Near(position, distance: 0))
        return entityFinder.getEntities(query)
    }

    private func entitiesInside(min min: Vec2d, max: Vec2d) -> [Entity] {
        let query = EntityQuery(filter: .Any, location: .AABB(AABB(min: min, max: max)))
        return entityFinder.getEntities(query)
    }
    
    private func update(state: State) {

        switch state {
        case .Selecting(let entity, _):
            selection.select(entity?.id, replace: !xorMode)
            fallthrough
        case .Idle:
            selectionUI.rect = .Hide
        case .MultiSelect(let from, let to):
            selection.select(entitiesInside(min: from, max: to).map{$0.id}, replace: !xorMode)
            selectionUI.rect = .Show(from, to)
        }
    }
}