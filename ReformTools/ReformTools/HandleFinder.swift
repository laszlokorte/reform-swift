//
//  HandleFinder.swift
//  ReformTools
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath
import ReformCore
import ReformStage
import ReformExpression


struct HandleQuery : Equatable {
    let filter: FormFilter
    let location : LocationFilter
}

func ==(lhs: HandleQuery, rhs: HandleQuery) -> Bool {
    return lhs.filter == rhs.filter && lhs.location == rhs.location
}

struct HandleFinder {
    let stage : Stage
    
    func getUpdatedHandle(_ oldHandle: Handle) -> Handle? {
        for entity in stage.entities
            where entity.id == oldHandle.formId {
                for handle in entity.handles
                    where handle.anchorId == oldHandle.anchorId {
                        return handle
                }
        }
        
        return nil
    }
    
    
    func getHandles(_ query: HandleQuery) -> [Handle] {
        var result = [Handle]()
        
        if case FormFilter.none = query.filter {
            return result
        }
        
    
        for entity in stage.entities {
            if query.filter.excludes(entity.id) {
                continue
            }
            
            for handle in entity.handles {
                guard query.location.matches(handle.position) else {
                    continue
                }
                result.append(handle)
            }
        
        }
    
      
        return result
    }
}
