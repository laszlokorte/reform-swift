//
//  AffineHandleFinder.swift
//  ReformTools
//
//  Created by Laszlo Korte on 21.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


import ReformMath
import ReformCore
import ReformStage
import ReformExpression


struct AffineHandleFinder {
    let stage : Stage

    func getUpdatedHandle(_ oldHandle: AffineHandle) -> AffineHandle? {
        for entity in stage.entities
            where entity.id == oldHandle.formId {
                for handle in entity.affineHandles
                    where handle == oldHandle {
                        return handle
                }
        }

        return nil
    }


    func getHandles(_ query: HandleQuery) -> [AffineHandle] {
        var result = [AffineHandle]()

        if case FormFilter.none = query.filter {
            return result
        }


        for entity in stage.entities {
            if query.filter.excludes(entity.id) {
                continue
            }

            for handle in entity.affineHandles {
                guard query.location.matches(handle.position) else {
                    continue
                }
                result.append(handle)
            }

        }


        return result
    }
}
