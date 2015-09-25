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

    func getUpdatedHandle(oldHandle: AffineHandle) -> AffineHandle? {
        for entity in stage.entities
            where entity.id == oldHandle.formId {
                for handle in entity.affineHandles
                    where handle == oldHandle {
                        return handle
                }
        }

        return nil
    }


    func getHandles(query: HandleQuery) -> [AffineHandle] {
        var result = [AffineHandle]()

        if case FormFilter.None = query.filter {
            return result
        }


        for entity in stage.entities {
            if case .Except(entity.id) = query.filter {
                continue
            }
            if case .Only(let id) = query.filter where id != entity.id {
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