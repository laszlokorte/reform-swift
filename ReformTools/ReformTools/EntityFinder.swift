//
//  EntityFinder.swift
//  ReformTools
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath
import ReformCore
import ReformStage
import ReformExpression


struct EntityQuery {
    let filter: FormFilter
    let location: LocationFilter
}

struct EntityFinder {
    let stage : Stage
    
    func getEntity(_ id: FormIdentifier) -> Entity? {
        for entity in stage.entities {
            if entity.id.runtimeId == id {
                return entity
            }
        }
        
        return nil
    }
    
    func getEntities(_ query: EntityQuery) -> [Entity] {
        var result = [Entity]()
        
        for entity in stage.entities {
            if case .except(entity.id) = query.filter {
                continue
            }
            if case .only(let id) = query.filter where id != entity.id {
                continue
            }


            guard query.location.matches(entity.hitArea) else {
                continue
            }
            
            result.append(entity)
        }
        
        return result
    }
}
